default['wn_isc_stork'] = {
  'agent' => {
    'env' => {
      # avoid conflict with stork-server
      'stork_agent_port' => '8081',
    },
  },
  'server' => {
    'env' => {
      'stork_rest_static_files_dir' => '/usr/share/stork/www',
      'stork_rest_versions_url' => 'https://www.isc.org/versions.json',
    },
  },
}
