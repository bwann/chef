#
# Cookbook:: wn_isc_stork
# Recipe:: server
#
# Copyright:: 2025-2026, Bryan Wann
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

unless node.rhel_family? || node.fedora_family? || node.debian_family?
  fail 'wn_kea: unsupported platform'
end

FB::Users.initialize_group(node, 'stork-server')
node.default['fb_users']['users']['stork-server'] = {
  'gid' => 'stork-server',
  'shell' => '/bin/bash',
  'home' => '/var/lib/stork-server',
  'action' => :add,
}

package 'isc-stork-server' do
  action :upgrade
end

# Modify group after installing package, which sets up user
# not sure why stork-server needs kea perms when agent reads files?
kea_group = node.debian_family? ? '_kea' : 'kea'

node.default['fb_users']['groups'][kea_group]['members'] += ['stork-server']

directory '/etc/stork' do
  mode '0755'
  owner 'root'
  group 'root'
end

template '/etc/stork/server.env' do
  source 'server.env.erb'
  mode '0640'
  owner 'root'
  group 'stork-server'
  notifies :restart, 'service[isc-stork-server]'
end

# stork-server rewrites this file at startup to inject STORK_REST_BASE_URL
file '/usr/share/stork/www/index.html' do
  owner 'stork-server'
  group 'root'
  mode '0644'
end

node.default['fb_iptables']['filter']['INPUT']['rules']['isc-stork-server'] = {
  'rule' => '-p tcp --dport 8080 -j ACCEPT',
}

directory '/var/log/stork' do
  mode '0750'
  owner 'root'
  group 'root'
end

node.default['fb_syslog']['rsyslog_early_lines'] += [
  ':programname, isequal, "stork-server" -/var/log/stork/server.log',
  '& stop',
]

node.default['fb_logrotate']['configs']['stork-server'] = {
  'files' => ['/var/log/stork/server.log'],
  'time' => 'daily',
}

service 'isc-stork-server' do
  action [:enable, :start]
end
