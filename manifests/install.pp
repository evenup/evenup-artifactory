# == Class: artifactory::install
#
# This class installs artifactory.  It should not be called directly
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
class artifactory::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  File {
    require => Package['artifactory'],
  }

  user { 'artifactory':
    ensure => 'present',
    system => true,
    shell  => '/bin/bash',
    home   => '/var/opt/jfrog/artifactory',
    gid    => 'artifactory',
  }

  group { 'artifactory':
    ensure => 'present',
    system => true,
  }

  package { 'artifactory':
    ensure  => $artifactory::ensure,
    notify  => Class['artifactory::service'],
    require => [ User['artifactory'], Group['artifactory'] ]
  }

  file { '/data/artifactory_data':
    ensure => directory,
    mode   => '0775',
    owner  => artifactory,
    group  => artifactory,
  }

  file { '/data/artifactory_backups':
    ensure => directory,
    mode   => '0775',
    owner  => artifactory,
    group  => artifactory,
  }

  file { '/var/opt/jfrog/artifactory/data':
    ensure => link,
    target => '/data/artifactory_data',
  }

}
