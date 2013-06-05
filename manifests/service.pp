# == Class: artifactory::service
#
# This class manages the artifactory service.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class artifactory::service {

  service { 'artifactory':
    ensure  => running,
    enable  => true,
  }

}
