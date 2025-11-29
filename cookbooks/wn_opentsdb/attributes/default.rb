# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

default['wn_opentsdb'] = {
  'sysconfig' => {},
  'conf' => {
    'tsd.core.auto_create_metrics' => true,
    'tsd.http.cachedir' => '/dev/shm/tsd-cache',
    'tsd.http.staticroot' => '/usr/share/opentsdb/static',
    'tsd.network.port' => '4242',
    'tsd.storage.hbase.zk_quorum' => '127.0.0.1',
  },
}
