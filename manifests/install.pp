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
class artifactory::install(
  $ensure       = 'latest',
  $serverAlias  = 'artifactory',
) {

  package { 'artifactory':
    ensure  => $ensure,
    notify  => Class['artifactory::service'],
  }

  file { '/data/artifactory_data':
    ensure  => directory,
    mode    => 0775,
    owner   => artifactory,
    group   => artifactory,
  }

  file { '/data/artifactory_backups':
    ensure  => directory,
    mode    => 0775,
    owner   => artifactory,
    group   => artifactory,
  }

  file { '/var/lib/artifactory/data':
    ensure  => link,
    target  => '/data/artifactory_data',
    require => Package['artifactory'],
  }

  apache::vhost { 'artifactory_80':
    serverName        => $::fqdn,
    serverAlias       => $serverAlias,
    port              => '80',
    proxy             => true,
    proxyTomcat       => true,
    ajpPort           => 8091,
    modSecOverrides   => true,
    modSecRemoveById  => [ '950901', '960024', '960010', '960015', '960020', '973332', '973333', '981173', '981243' ],
    modSecBodyLimit   => 524288000,
    logstash          => true,
  }

  backups::archive { 'artifactory':
    path      => '/data/artifactory_backups',
    hour      => 6,
    minute    => 10,
    keep      => 7,
    tmp_path  => '/data/tmp';
  }

}
