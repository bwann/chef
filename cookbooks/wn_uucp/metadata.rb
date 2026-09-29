name 'wn_uucp'
maintainer 'Bryan Wann'
maintainer_email 'bwann-chef@wann.net'
license 'Apache-2.0'
source_url 'https://github.com/bwann/chef'
description 'Installs/Configures Taylor UUCP'
# never EVER change this number, ever.
version '0.1.0'
%w{
  fb_cron
  fb_helpers
  fb_users
}.each do |dep|
  depends dep
end
