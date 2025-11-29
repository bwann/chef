# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook:: wn_opentsdb
# Recipe:: default
#
# Author:: Bryan Wann (<bwann-chef@wann.net>)
#
# Copyright:: 2018-2025, Bryan Wann
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

include_recipe 'wn_java'

# TODO: migrate user/group management to fb_users

group 'opentsdb'

user 'opentsdb' do
  home '/usr/share/opentsdb/'
  shell '/sbin/nologin'
  uid '421'
  gid 'opentsdb'
  manage_home false
end

packages = %w{
  gnuplot
  opentsdb
}

package packages do
  action :upgrade
end

# PNG cache dir, in-memory on tmpfs
directory '/dev/shm/tsd-cache' do
  owner 'opentsdb'
  group 'opentsdb'
  mode '0755'
  action :create
end

directory '/var/log/opentsdb' do
  owner 'opentsdb'
  group 'opentsdb'
  mode '0755'
  action :create
end

directory '/etc/opentsdb' do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
end

template '/etc/opentsdb/opentsdb.conf' do
  source 'opentsdb.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[opentsdb]'
end

# XXX: For whatever reason /etc/opentsdb/ should've been symlinked to
# /usr/share/opentsdb/etc/ but broken in 2.2.0 RPM? This makes things happy
cookbook_file '/etc/opentsdb/logback.xml' do
  source 'logback.xml'
  mode '0644'
  owner 'root'
  group 'root'
end

template '/etc/sysconfig/opentsd' do
  source 'tsd.sysconfig.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[opentsdb]'
end

node.default['fb_cron']['jobs']['cleanup tsd cache'] = {
  'time' => '0 * * * *',
  'command' =>
    'find /dev/shm/tsd-cache -maxdepth 1 -type f -mtime +1 ' \
    '-exec /bin/rm -f {} \;',
}

cookbook_file '/etc/init.d/opentsdb' do
  only_if { node.centos7? }
  source 'opentsdb.init'
  mode '0755'
  owner 'root'
  group 'root'
  action :create_if_missing
end

cookbook_file '/etc/systemd/system/opentsdb.service' do
  not_if { node.centos7? }
  source 'opentsdb.service'
  mode '0644'
  owner 'root'
  group 'root'
end

cookbook_file '/root/tsd-server-stats.sh' do
  source 'tsd-server-stats.sh'
  mode '0755'
  owner 'root'
  group 'root'
end

execute 'starting TSD stats gatherer' do
  command '/root/tsd-server-stats.sh &'
  not_if 'pgrep -f tsd-server-stats.sh'
end

service 'opentsdb' do
  action [:start, :enable]
end
