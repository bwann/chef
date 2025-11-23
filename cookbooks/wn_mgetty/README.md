wn_mgetty Cookbook
==================
Installs mgetty, to handle all aspects of a modem and login under UNIX/Linux

Requirements
------------

Attributes
----------
* node['wn_mgetty']['dialin']
* node['wn_mgetty']['enable_port']
* node['wn_mgetty']['global'][$KEY]
* node['wn_mgetty']['login']
* node['wn_mgetty']['port']
* mode['wn_mgetty']['issue_file']

Usage
-----
Include `wn_mgetty::default` recipe to setup mgetty. For more information
about how to configure mgetty, refer to the `mgetty(8)` man page or files
in `/usr/share/doc/mgetty`.

* `node['wn_mgetty']['enable_port']` is a serial port to start mgetty on.
This cookbook will create a systemd unit for this port,
 e.g. `mgetty@ttyS3.service`

* `node['wn_mgetty']['global']` is a hash of key/value items for global
configuration options.  In particular this sets things like debug level,
serial port speed, ownership+mode of tty devices.

Example:

- To set the speed at which to access the modem at 57,600 bps, set the
attribute `node.default['wn_getty']['global']['speed'] = 57600`.

- To set the serial port to be owned by `uucp.uucp` and mode `rw-rw-r--`,
for use with UUCP, set theses attributes (otherwise package defaults
are used):

```ruby
node.default['wn_getty']['global']['port-owner'] = 'uucp'
node.default['wn_getty']['global']['port-group'] = 'uucp'
node.default['wn_getty']['global']['port-mode'] = '0664'
```

* `node['wn_mgetty']['port']` is a hash of hashes of key/value items for
individual port configuration, indexed by the serial device name.

Example:

```ruby
# Configure only an init-string ("init-chat") for the modem on /dev/ttyUSB0

node.default['wn_getty']['port']['ttyUSB0']['init-chat'] =
  '"" \d\d\d+++\d\d\dATV1&C1&D2&K3&Q5S95=3S7=60%E0 OK'

# Configure multiple options for a ZyXEL modem on /dev/ttyS2
node.default['wn_getty']['port']['ttyS2'] = {
  'debug' => 8,
  'init-chat' => '"" \d\d\d+++\d\d\dAT&FS2=255 OK ATN3S0=0S13.2=1 OK',
  'statistics-chat' => '"" AT OK ATI2 OK',
  'statistics-file' => '/var/log/statistics.ttyS2',
  'modem-type' => 'cls2',
}
```

* `node['wn_mgetty']['dialin']` is an array of values for matching on
caller ID to limit or disallow from which this system can be called.
By default this file is empty. (This is the dialin.config file)

* `node['wn_getty']['login']` is an array of "login dispatchers" to control
what mgetty does once it has answered the phone.  The order of this file is
important as usernames are matched in order of the array, so it's not
recommended to manipulate this attribute in multiple places, unless care is
taken. (This is the login.config file)

By default this is set to `*       -       -       /bin/login @` to spawn
`/bin/login` on each inbound connection.

Example:

```bash
# - If the username given starts with a 'U' consider it a UUCP caller and
# start uucico, and
# - If a PPP caller is detected, launch pppd, and
# - all others start a login shell:

node.default['wn_getty']['login'] = [
  'U*      uucp    @       /usr/lib/uucp/uucico -l -u @',
  '/AutoPPP/  -    a_ppp   /usr/sbin/pppd auth -chap +pap login debug',
  '*   -    -   /bin/login @',
]
```

* `mode['wn_mgetty']['issue_file']` is an array of lines that are written
pre-login before the mgetty login prompt. On most OSes this is the
`/etc/issue.mgetty` file.  The `mgettydefs(4)` file can help with
substitution variables.  By default this is empty.

Example: 

```bash
# To display the system name, serial port (\P), and CONNECT attributes

node.default['wn_getty']['issue_file'] = [
 '\s \P \S (\I)',
 '',
 'Welcome to my system!',
]

Would display something like this to a modem caller:

Linux ttyUSB0 57600 (9600/ARQ)

Welcome to my system!

login:
```
