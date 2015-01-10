# == Class: artifactory::config
#
# This class configures artifactory.  It should not be called directly
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
class artifactory::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/opt/jfrog/artifactory/tomcat/conf/server.xml':
    ensure => file,
    owner  => artifactory,
    group  => artifactory,
    mode   => '0444',
    source => 'puppet:///modules/artifactory/server.xml',
    notify => Class['artifactory::service'],
  }

}
