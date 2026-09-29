# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
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

# fb_users requires a site to define its own UID/GID maps. These cover the
# service accounts managed by cookbooks under test.
module FB
  class Users
    UID_MAP = {
      'kea' => {
        'uid' => 202,
        'system' => true,
      },
      '_kea' => {
        'uid' => 203,
        'system' => true,
      },
      'exabgp' => {
        'uid' => 204,
        'system' => true,
      },
    }.freeze

    GID_MAP = {
      # fb_users' default primary group (user_defaults), must be mapped
      'users' => {
        'gid' => 100,
        'system' => true,
      },
      'kea' => {
        'gid' => 202,
        'system' => true,
      },
      '_kea' => {
        'gid' => 203,
        'system' => true,
      },
      'exabgp' => {
        'gid' => 204,
        'system' => true,
      },
    }.freeze
  end
end
