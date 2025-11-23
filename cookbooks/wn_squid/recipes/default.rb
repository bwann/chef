# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook:: wn_squid
# Recipe:: default
#
# Copyright:: 2015-present, Bryan Wann
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

package 'squid' do
  action :upgrade
end

squid_group = node.centos? ? 'squid' : 'proxy'
squid_user = node.centos? ? 'squid' : 'proxy'

group squid_group do
  action :create
end

squid_spool = '/var/spool/squid'

user squid_user do
  gid squid_group
  home squid_spool
  action [:create, :lock]
end

directory squid_spool do
  mode '0750'
  owner squid_user
  group squid_group
  action :create
end

template '/etc/squid/squid.conf' do
  source 'squid.conf.erb'
  mode '0640'
  owner 'root'
  group squid_group
  notifies :reload, 'service[squid]'
end

service 'squid' do
  action [:enable, :start]
end
