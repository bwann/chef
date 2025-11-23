#
# Cookbook:: wn_containerd
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

package 'containerd.io' do
  action :upgrade
end

directory '/etc/containerd' do
  mode '0755'
  owner 'root'
  group 'root'
end

template '/etc/containerd/config.toml' do
  source 'config.toml.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[containerd]'
end

service 'containerd' do
  action [:enable, :start]
end
