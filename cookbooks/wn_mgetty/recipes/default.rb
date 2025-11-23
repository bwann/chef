#
# Cookbook:: wn_mgetty
# Recipe:: default
#
# Copyright:: 2025-present, Bryan Wann
# All rights reserved.
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

package 'mgetty' do
  action :upgrade
end

# Presented to callers before they get login prompt
template '/etc/issue.mgetty' do
  source 'issue.mgetty.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

config_dir = value_for_platform(
  'centos' => { :default => '/etc/mgetty+sendfax' },
  :default => '/etc/mgetty',
)

%w{
  dialin.config
  login.config
  mgetty.config
}.each do |config_file|
  template "#{config_dir}/#{config_file}" do
    source "#{config_file}.erb"
    mode '0400'
    owner 'root'
    group 'root'
  end
end

# Weirdly there's no packaged systemd unit file on Debian
cookbook_file '/etc/systemd/system/mgetty@.service' do
  only_if { node.debian? }
  source 'mgetty.service'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
end

# TODO: remember how to write a LWRP or custom resource to manage multiple
# mgetty systemd units instead of just a single one

service 'enabling mgetty instances' do
  service_name lazy { "mgetty@#{node['wn_mgetty']['enable_port']}" }
  action [:enable, :start]
  subscribes :reload, "template[#{config_dir}/mgetty.config]"
end
