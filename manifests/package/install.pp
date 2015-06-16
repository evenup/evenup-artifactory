# == Class: artifactory::package::install
#
# This class installs artifactory.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class artifactory::package::install inherits artifactory::params {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  user { 'artifactory':
    ensure => 'present',
    system => true,
    shell  => '/bin/bash',
    home   => $::artifactory::params::std_user_home,
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
    notify   => Class['artifactory::package::service'],
    require  => [ User['artifactory'], Group['artifactory'] ],
  }

  if $::artifactory::data_path != $::artifactory::params::std_data_path {
    file { $::artifactory::data_path:
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    }

    file { $::artifactory::params::std_data_path:
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
