default['wn_kea'] = {
  'dhcp4' => {
    'interfaces-config' => {
      'interfaces' => ['eth0'],
    },
    'control-socket' => {
      'socket-type' => 'unix',
      'socket-name' => 'kea4-ctrl-socket',
    },
    'lease-database' => {
      'type' => 'memfile',
      'lfc-interval' => 3600,
    },
    'expired-leases-processing' => {
      'reclaim-timer-wait-time' => 10,
      'flush-reclaimed-timer-wait-time' => 25,
      'hold-reclaimed-time' => 3600,
      'max-reclaim-leases' => 100,
      'max-reclaim-time' => 250,
      'unwarned-reclaim-cycles' => 5,
    },
    'renew-timer' => 900,
    'rebind-timer' => 1800,
    'valid-lifetime' => 3600,
    'subnet4' => {},
    'option-data' => [],
    'loggers' => [
      {
        'name' => 'kea-dhcp4',
        'output_options' => [
          {
            'output' => '/var/log/kea/kea-dhcp4.log',
            'pattern' => "%-5p %m\n",
            'maxsize' => 1048576,
            'maxver' => 8,
          },
        ],
        'severity' => 'DEBUG',
        'debuglevel' => 2,
      },
    ],
  },

  'dhcp6' => {
    'interfaces-config' => {
      'interfaces' => ['eth0'],
    },
    'control-socket' => {
      'socket-type' => 'unix',
      'socket-name' => 'kea6-ctrl-socket',
    },
    'lease-database' => {
      'type' => 'memfile',
      'lfc-interval' => 3600,
    },
    'expired-leases-processing' => {
      'reclaim-timer-wait-time' => 10,
      'flush-reclaimed-timer-wait-time' => 25,
      'hold-reclaimed-time' => 3600,
      'max-reclaim-leases' => 100,
      'max-reclaim-time' => 250,
      'unwarned-reclaim-cycles' => 5,
    },
    'mac-sources' => [
      'duid',             # DUID-LL/LLT embeds MAC; works for on-link, relay, and multicast probes
      'rfc6939',          # Client Link-Layer Address option (relayed clients without DUID-LL)
      'ipv6-link-local',  # last resort: extract from EUI-64 link-local (non-DUID-LL clients)
    ],
    'host-reservation-identifiers' => [
      'duid',
      'hw-address',
    ],
    'renew-timer' => 1000,
    'rebind-timer' => 2000,
    'preferred-lifetime' => 3000,
    'valid-lifetime' => 4000,
    'subnet6' => {},
    'option-data' => [],
    'loggers' => [
      {
        'name' => 'kea-dhcp6',
        'output_options' => [
          {
            'output' => '/var/log/kea/kea-dhcp6.log',
            'pattern' => "%-5p %m\n",
            'maxsize' => 1048576,
            'maxver' => 8,
          },
        ],
        'severity' => 'INFO',
        'debuglevel' => 0,
      },
    ],
  },
}
