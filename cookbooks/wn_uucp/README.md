wn_uucp Cookbook
================
Installs and configures Taylor UUCP, suitable for both modem and TCP transport.

Requirements
------------

Attributes
----------
* node['wn_uucp']['email']
* node['wn_uucp']['call']
* node['wn_uucp']['config']['nodename']
* node['wn_uucp']['passwd']
* node['wn_uucp']['port']
* node['wn_uucp']['sys']

Usage
-----
Include this recipe from your node's role or role cookbook. At the bare minimum
you need to set these attributes to get reports from cron and to set your
UUCP site name for receiving/sending jobs to other UUCP sites.

```ruby
include_recipe 'wn_uucp'

# e-mail for generated reports
node.default['wn_uucp']['email'] = 'me@example.com'

# your system's UUCP site name
node.default['wn_uucp']['config']['nodename'] = 'mysite'
```

UUCP over TCP is untested and unsupported. This cookbook was originally
designed to use with mgetty (via the `wn_mgetty` cookbook) and dial-up modems.
Performing UUCP over TCP/SSH connections is a goal and support will eventually
be added.

### CentOS/Fedora note (uudemon scripts)

Technically this cookbook will work on CentOS/Fedora when used with the `uucp`
and `cu` packages from Fedora. However those packages are lacking two
recommended hourly and daily housekeeping scripts (e.g. `/usr/lib/uucp/uudemon.hr`
and `uudemon.day`) which takes care of periodic checking of any pending jobs
to/from remote sites. (These may have originated with BNU/HDB UUCP?)

These scripts are however packaged with the Debian `uucp` package. Therefore this
cookbook is officially targeted running on Debian platforms, instead of trying to
bundle GPL 2.0 code with this cookbook to make up for it on CentOS/Fedora-based
systems.

### Packages

Debian vs CentOS packaging - This cookbook was written to support CentOS,
Debian, and Raspbian systems. There are slight differences in how files were
packaged, file/directory ownership, etc. between the distributions. This
cookbook tries to make sensible compromises so UUCP is operated consistently
on all platforms.

Debian still ships with the `uucp` package, whereas on EL/Fedora/CentOS-based
systems you'll need to use the packages from somewhere like Fedora.

### Quick notes

* `~` (tilde) in UUCP software often refers to the "public" UUCP directory
(such as `/var/spool/uucppublic`) and not a user home directory. Be mindful
when using tilde on a shell prompt as the shell could interpret it as your
home directory. Most of UUCP of depends on writing to the uucppublic directory,
then users manually copying files in/out of there.

### Security
The entire UUCP sub-system isn't the most secure thing, it was born during
a time when there was more trust between users. For example it often depends on
world-writable directories which means other users on the same system can
read/delete/overwrite/alter files for example in the public UUCP directory.
File permissions are the only thing keeping people from snooping around.

Taylor UUCP keeps its own password file and by default passwords are
plain-text. (The software can be re-compiled to add some crypt() support)

The good news with Taylor UUCP having its own password file, if you were
running a UUCP hub that only provided `uucico` services, you do not have
to give a shell account to users. This greatly limits the attack surface.

### Example usage

* Configure a modem "dialer" called `usrsportster` on a USB-serial adapter at
`/dev/ttyUSB0`:

```ruby
node.default['wn_uucp']['port']['usrsportster'] = {
  'device' => '/dev/ttyUSB0',
  'dialer' => 'hayes',
  'speed' => '57600',
}

```

* Incoming config for remote site -> your site:

```ruby
# call-in password, remotesite -> mysite
node.default['wn_uucp']['passwd']['Uremotesite'] = 'secretpassword'

node.default['wn_uucp']['sys']['systems']['remotesite'] = {
  'called-login' => 'Uremotesite',
  'protocol-parameter g errors' => '200',
  'protocol-parameter g retries' => '10',
  'forward' => 'ANY',
  'forward-to' => 'ANY',
  'time' => 'Any 30',
}
```

* Outbound config for your site -> remote site:

```ruby
# call-out password, mysite -> remote
node.default['wn_uucp']['call']['remote'] = {
  'username' => 'Umysite',
  'password' => 'mysecurepassword',
}

additional Systems config for how to contact the remote site:

node.default['wn_uucp']['sys']['systems']['remotesite'] = {
  'call-login' => 'Umysite',
  # call-passwords saved in 'call' file, so '*' here
  'call-password' => '*',
  'protocol-parameter g errors' => '200',
  'protocol-parameter g retries' => '10',
  'forward' => 'ANY',
  'forward-to' => 'ANY',
  'time' => 'Any 30',
  'phone' => '5105551212',
}
```

Extra resources
---------------
There's an old but excellent -- and still relevant -- O'Reilly book for setting up UUCP,
including Taylor UUCP:

* Ravin, E., O’Reilly, T., Dougherty, D., & Todino, G. (1996, Second Edition).
___Using & managing UUCP___. O’Reilly & Associates.

Not to be confused with the older UUCP and Usenet book that only covers
HoneyDanBer UUCP/BNU and Version 2:

* O'Reilly, T and Todino, G. (1992, Tenth Edition).
___Managing uucp and usenet___. O'Reilly & Associates.

Both are available on the Internet Archive.
