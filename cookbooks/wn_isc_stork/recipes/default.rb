#
# Cookbook:: wn_isc_stork
# Recipe:: default
#
# Copyright:: 2025, wann.net, All Rights Reserved.

# This installs the Stork Agent, should be installed on any systems with
# Kea or BIND servers

unless node.rhel_family? || node.fedora_family? || node.debian_family?
  fail 'wn_kea: unsupported platform'
end

FB::Users.initialize_group(node, 'stork-agent')
node.default['fb_users']['users']['stork-agent'] = {
  'gid' => 'stork-agent',
  'shell' => '/bin/bash',
  'home' => '/var/lib/stork-agent',
  'action' => :add,
}

kea_group = node.debian_family? ? '_kea' : 'kea'

package 'isc-stork-agent' do
  action :upgrade
end

# Add stork-agent to kea group so it can examine kea leases/logs
node.default['fb_users']['groups'][kea_group]['members'] += ['stork-agent']

# Add stork-agent to named group so it can read named.conf/rndc.conf for
# monitoring BIND 9. Not the greatest check but it works.
if Dir.exist?('/var/named')
  named_group = node['wn_bind']['named_group']
  node.default['fb_users']['groups'][named_group] = {
    'members' => ['stork-agent'],
    'action' => :add,
  }
end

template '/etc/stork/agent.env' do
  source 'agent.env.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[isc-stork-agent]'
end

node.default['fb_iptables']['filter']['INPUT']['rules']['isc-stork-agent'] = {
  'rules' => [
    # agent
    '-p tcp --dport 8081 -j ACCEPT',
    # prometheus kea exporter, if installed
    '-p tcp --dport 9547 -j ACCEPT',
  ],
}

directory '/var/log/stork' do
  mode '0750'
  owner node.debian_family? ? 'syslog' : 'root'
  group 'root'
end

node.default['fb_syslog']['rsyslog_early_lines'] += [
  ':programname, isequal, "stork-agent" -/var/log/stork/agent.log',
  '& stop',
]

node.default['fb_logrotate']['configs']['stork-agent'] = {
  'files' => ['/var/log/stork/agent.log'],
  'time' => 'daily',
}

service 'isc-stork-agent' do
  action [:enable, :start]
end
