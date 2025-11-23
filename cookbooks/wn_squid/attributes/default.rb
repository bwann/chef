# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

default['wn_squid'] = {
  'acl' => {
    'chat_ports' => ['port 5228'], # XMPP
    'connect' => [
      'method CONNECT',
    ],
    'localnet' => [
      'src 10.0.0.0/8',      # RFC 1918
      'src 100.64.0.0/10',   # RFC 6598
      'src 169.254.0.0/16',  # RFC 3927
      'src 172.16.0.0/12',   # RFC 1918
      'src 192.168.0.0/16',  # RFC 1918
      'src fc00::/7',        # RFC 4193
      'src fe80::/10',       # RFC 4291
    ],
    'push_ports' => ['port 5223'], # Push notifications
    'safe_ports' => [
      'port 80',          # http
      'port 21',          # ftp
      'port 443',         # https
      'port 70',          # gopher
      'port 210',         # wais
      'port 1025-65535',  # unregistered ports
      'port 280',         # http-mgmt
      'port 488',         # gss-http
      'port 591',         # filemaker
      'port 777',         # multiling http
    ],
    'ssl_ports' => ['port 443'],
  },
  'cache_dir' => [],
  'coredump_dir' => '/var/spool/squid',
  'http_access' => [
    'deny !Safe_ports',
    'deny CONNECT !SSL_ports',
    'allow localhost manager',
    'deny manager',
    'allow localnet',
    'allow localhost',
    'deny all',
  ],
  'http_port' => 3128,
  'refresh_pattern' => [
    '^ftp:              1440  20% 10080',
    '-i (/cgi-bin/|\?)  0      0%     0',
    '.                  0     20%  4320',
  ],
}
