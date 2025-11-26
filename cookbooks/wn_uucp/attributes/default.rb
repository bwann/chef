default['wn_uucp'] = {
  'email' => 'root',
  'call' => {},
  'config' => {},
  'passwd' => {},
  'port' => {
    # ACU is a traditional port name and not really special
    # NOTE: Make SURE this device is owned by root:dialout, mode 0660
    'ACU' => {
      'type' => 'modem',
      'device' => '/dev/ttyUSB0',
      'dialer' => 'hayes',
      'speed' => '57600',
    },
  },
  'sys' => {
    'defaults' => {},
    'systems' => {},
  },
}
