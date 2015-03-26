# == Class: artifactory::install
#
# This class installs artifactory.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
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
    ensure   => $::artifactory::ensure,
    provider => $::artifactory::package_provider,
    source   => $::artifactory::package_source,
    notify   => Class['artifactory::service'],
    require  => [ User['artifactory'], Group['artifactory'] ],
  }

  if $::artifactory::data_path != '/var/opt/jfrog/artifactory/data' {
    file { $::artifactory::data_path:
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    }

    file { '/var/opt/jfrog/artifactory/data':
      ensure => link,
      target => $::artifactory::data_path,
    }
  }

  if $::artifactory::backup_path {
    file { $::artifactory::backup_path:
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    }
  }

}
