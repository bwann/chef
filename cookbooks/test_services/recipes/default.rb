# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook:: test_services
# Recipe:: default
#
# Copyright:: 2026-present, Bryan Wann
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

# Stand-ins for what fb_init would normally provide on a real host
include_recipe 'fb_systemd::reload'
include_recipe 'fb_users'

# wn_kea installs ISC's own isc-kea-* packages rather than distro packages,
# so point CI at ISC's Cloudsmith repos.
kea_repo = 'https://dl.cloudsmith.io/public/isc/kea-3-0'
if node.debian_family?
  # Debian's platform_version is the point release (e.g. 12.7)
  os = node.debian? ? "debian-#{node['platform_version'].to_i}" :
    "ubuntu-#{node['platform_version']}"
  codename = {
    'debian-12' => 'bookworm',
    'ubuntu-22.04' => 'jammy',
    'ubuntu-24.04' => 'noble',
  }[os]
  fail "test_services: no ISC Kea repo for #{os}" unless codename

  package %w{ca-certificates gnupg} do
    action :upgrade
  end

  apt_repository 'isc-kea' do
    uri "#{kea_repo}/deb/#{node['platform']}"
    distribution codename
    components ['main']
    key "#{kea_repo}/gpg.key"
  end
else
  yum_repository 'isc-kea' do
    description 'ISC Kea'
    baseurl "#{kea_repo}/rpm/#{node.fedora? ? 'fedora' : 'el'}/$releasever/$basearch"
    gpgkey "#{kea_repo}/gpg.key"
    gpgcheck true
    repo_gpgcheck true
  end
end

include_recipe 'wn_squid'

# ISC's kea-3-0 repo only has packages for Fedora 41+ (fedora/40 is empty)
unless node.fedora_max_version?(40)
  include_recipe 'wn_kea'
end

# exabgp is in EPEL 9 and Fedora, but not EPEL 10
unless node.el_min_version?(10)
  node.default['wn_exabgp']['neighbor']['127.0.0.1'] = {
    'router-id' => '127.0.0.1',
    'local-address' => '127.0.0.1',
    'local-as' => 65000,
    'peer-as' => 65001,
  }
  include_recipe 'wn_exabgp'
end

# mgetty isn't packaged for EL9/EL10, not even in EPEL. No serial port in a
# container, so this only exercises the package and config file rendering.
unless node.rhel_family?
  include_recipe 'wn_mgetty'
end
