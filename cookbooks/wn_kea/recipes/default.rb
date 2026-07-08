#
# Cookbook:: wn_kea
# Recipe:: default
#
# Copyright:: 2024-2026, Bryan Wann
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

kea_group = node.centos? ? 'kea' : '_kea'
kea_user = node.centos? ? 'kea' : '_kea'

# Add kea user and group
FB::Users.initialize_group(node, kea_group)
node.default['fb_users']['users'][kea_user] = {
  'gid' => kea_group,
  'shell' => '/bin/bash',
  'home' => '/var/lib/kea',
  'action' => :add,
}

packages = value_for_platform(
  'centos' => {
    'default' => %w{
      isc-kea
      isc-kea-common
      isc-kea-dhcp4
      isc-kea-dhcp6
      isc-kea-hooks
    },
  },
  ['debian', 'ubuntu'] => {
    'default' => %w{
      isc-kea-admin
      isc-kea-common
      isc-kea-dhcp4
      isc-kea-dhcp6
      isc-kea-hooks
    },
  },
)

package packages do
  action :upgrade
end

directory '/etc/kea' do
  mode '0750'
  owner node.root_user
  group kea_group
end

directory '/var/lib/kea' do
  mode '0750'
  owner kea_user
  group kea_group
end

# Enforce perms if this exists
file '/etc/kea/kea-api-password' do
  mode '0640'
  owner 'root'
  group kea_group
end

# Kea expects each subnet to have a unique subnet-id which would normally
# lend itself to being a handy key in a config hash but it's not very
# user-friendly, especially when we want to do things like override pools
# from different recipes. The user would need to know the subnet-id of a given
# subnet they want to work on.
# 
# This cookbook is designed to use the actual subnet CIDR notation as the
# key in configs so the subnet-id is hidden away from the user and generated
# automatically in this recipe.
#
# Munge the subnets config from being keyed by subnet4/subnet6 to keyed
# by subnet id, and use a consistent hash to assign the subnet id so it
# doesn't change when subnets are added or removed.
%w{dhcp4 dhcp6}.each do |ver|
  whyrun_safe_ruby_block "munging #{ver} subnet config" do
    block do
      require 'zlib'
      key = ver == 'dhcp4' ? 'subnet4' : 'subnet6'

      cfg = {}
      node['wn_kea'][ver].each do |k, v|
        next if k == key
        cfg[k] = v.respond_to?(:to_hash) ? v.to_hash : v
      end

      subnets = node['wn_kea'][ver][key]
      if subnets.is_a?(Hash) && !subnets.empty?
        subnet_array = subnets.map do |cidr, config|
          entry = config.respond_to?(:to_hash) ? config.to_hash : {}
          if entry['pools']
            entry['pools'] = entry['pools'].map do |p|
              p.is_a?(String) ? { 'pool' => p } : p
            end
          end
          entry['subnet'] = cidr
          # CRC32 gives a stable uint32 ID per subnet regardless of what other
          # subnets are added or removed. Sequential sorted IDs would renumber
          # everything on insertion, and Kea ties memfile lease records to subnet ID.
          entry['id'] = Zlib.crc32(cidr)
          entry
        end

        ids = subnet_array.map { |s| s['id'] }
        # It should be impossible to fail here because we're organizing subnets in a hash,
        # which should guarantee uniqueness. probably more likely a bug
        fail "Kea #{key} ID collision detected" if ids.uniq.length != ids.length

        cfg[key] = subnet_array
      end

      node.default['wn_kea']["_munged_#{ver}_config"] = cfg
    end
  end
end

%w{kea-dhcp4 kea-dhcp6}.each do |version|
  template "/etc/kea/#{version}.conf" do
    source "#{version}.conf.erb"
    mode '0644'
    owner node.root_user
    group node.root_group
    notifies :restart, "service[#{version}]"
  end
end

service 'kea-dhcp4' do
  service_name node.centos? ? 'kea-dhcp4' : 'isc-kea-dhcp4-server'
  action [:enable, :start]
end

service 'kea-dhcp6' do
  service_name node.centos? ? 'kea-dhcp6' : 'isc-kea-dhcp6-server'
  action [:enable, :start]
end
