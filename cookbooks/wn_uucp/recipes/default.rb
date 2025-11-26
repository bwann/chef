#
# Cookbook:: wn_uucp
# Recipe:: default
#
# Copyright:: 2023-present, Bryan Wann
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

# Some of these may need to be moved to the base OS packages list
packages = value_for_platform(
  ['debian', 'raspbian', 'ubuntu'] => {
    'default' => [
      'bsd-mailx',
      'cu',
      'libevent-2.1-7',
      'liblockfile-bin',
      'liblockfile1',
      'openbsd-inetd',
      'ssl-cert',
      'tcpd',
      'update-inetd',
      'uucp',
    ],
  },
  'centos' => {
    'default' => [
      'cu',
      'libnsl',
      'uucp',
    ],
  },
)

unless packages
  fail 'wn_uucp included on an unsupported platform'
end

package packages do
  action :upgrade
end

# For UUCP login accounts (that actually have unix shell logins), e.g. U*
# accounts, it's recommended to set their primary group as 'uuguest'
group 'uuguest' do
  action :create
end

# Letting the package manage the user and group additions
# - Debian uucp uid is 10, uucp gid is 10, uuguest gid 115
# - CentOS uucp uid is 14, uucp gid is 14
#
# TODO: migrate user/creation to fb_users cookbook control

directory '/etc/uucp' do
  mode '0755'
  owner 'root'
  group 'root'
end

directory '/usr/lib/uucp/' do
  mode '0750'
  owner 'uucp'
  group 'uucp'
end

directory '/var/log/uucp' do
  mode '0755'
  owner 'uucp'
  group 'uucp'
end

directory '/var/spool/uucp' do
  mode '0755'
  owner 'uucp'
  group 'uucp'
end

directory '/var/spool/uucppublic' do
  mode '1755'
  owner 'uucp'
  group 'uucp'
end

# Scripts to run from cron/systemd timers:
# uudemon.day - Daily cleanup of uucp spool directory, sends email report
# uudemon.hr - Hourly script to poll/call for inbound or outstanding jobs
#
# %w{
#   uudemon.hr
#   uudemon.day
# }.each do |libfile|
#   cookbook_file "/usr/lib/uucp/#{libfile}" do
#     only_if { node.centos? }
#     source libfile
#     mode '0755'
#     owner 'root'
#     group 'root'
#   end
# end

# 'call' and 'passwd' contain passwords so they have restricted permissions
# Of note uucico is suid/sgid uucp:callout (at least on Debian) so to read the
# passwd file, it needs to be either owned by root:callout or uucp:uucp
#
# - on centos call and passwd are root:uucp mode 0640
%w{
  call
  passwd
}.each do |name|
  template "/etc/uucp/#{name}" do
    source "#{name}.erb"
    mode '0640'
    owner 'uucp'
    group 'uucp'
  end
end

# - on centos these are root:root mode 644
%w{
  config
  dial
  expire
  Poll
  port
}.each do |name|
  template "/etc/uucp/#{name}" do
    source "#{name}.erb"
    mode '0644'
    owner 'root'
    group 'uucp'
  end
end

# 'sys' ordering is important, defaults first, then system defintions.
# systems can have multiple alternates, callin/callout, dial/tcp
# XXX: todo support alternate
template '/etc/uucp/sys' do
  source 'sys.erb'
  mode '0644'
  owner 'root'
  group 'uucp'
end

# Cron jobs
#
# On systemd systems logrotate is run via logrotate.timer at 00:00:00, yet
# uudemon.day is still launched by cron during cron.daily at 6am. This means
# uudemon.day stats only have 6 hours of logs to process.
# Re-schedule uudemon.day

cron_jobs = {
  'process/retry waiting jobs periodically' => {
    'time' => '25,55 * * * *',
    'command' => 'su -s /bin/bash uucp -c "/usr/sbin/uucico -r1"',
  },
  'daily uucp spool cleanup, stats generation' => {
    'time' => '59 23 * * *',
    'command' => 'su -s /bin/bash uucp -c "/usr/lib/uucp/uudemon.day ' +
      node['wn_uucp']['email'] + '"',
  },
  'hourly uucp tasks' => {
    'time' => '0 * * * *',
    'command' => 'su -s /bin/bash uucp -c "/usr/lib/uucp/uudemon.hr"',
  },
}

cron_jobs.each do |name, details|
  node.default['fb_cron']['jobs'][name] = details
end

file '/etc/cron.daily/uucp' do
  action :delete
end
