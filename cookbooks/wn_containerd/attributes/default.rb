default['wn_containerd'] = {
  'config' => {
    '_global' => {
      'disabled_plugins' => [],
      'root' => '/var/lib/containerd',
      'state' => '/run/containerd',
      'subreaper' => true,
      'oom_score' => 0,
      'version' => 2,
    },
    'grpc' => {
      'address' => '/run/containerd/containerd.sock',
      'uid' => 0,
      'gid' => 0,
    },
    'debug' => {
      'address' => '/run/containerd/debug.sock',
      'uid' => 0,
      'gid' => 0,
      'level' => 'info',
    },
  },
}
