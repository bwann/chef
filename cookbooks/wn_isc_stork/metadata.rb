name 'wn_isc_stork'
maintainer 'Bryan Wann'
maintainer_email 'bwann-chef@wann.net'
license 'Apache-2.0'
source_url 'https://github.com/bwann/chef'
description 'Installs/Configures ISC Stork web UI for Kea'
# never EVER change this number, ever.
version '0.1.0'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'ubuntu'

%w{
  fb_users
  fb_iptables
  fb_syslog
  fb_logrotate
}.each do |dep|
  depends dep
end
