# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook:: wn_exabgp
# Recipe:: default
#
# Copyright:: 2018-present, Bryan Wann
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

# Set up the exabgp group and user
FB::Users.initialize_group(node, 'exabgp')
node.default['fb_users']['users']['exabgp'] = {
  'gid' => 'exabgp',
  'shell' => '/sbin/nologin',
  'home' => '/run/exabgp',
  'action' => :add,
  'manage_home' => false,
}

packages = %w{exabgp python3-exabgp}

package packages do
  action :upgrade
end

template '/etc/exabgp/exabgp.conf' do
  source 'exabgp.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[exabgp]'
end

service 'exabgp' do
  action [:enable, :start]
end
