# == Class: artifactory
#
# This class installs and configures artifactory, apache vhost, and backups.
#
#
# === Parameters
#
# [*serverAlias*]
#   String of comman seperated hostnames or array of hostnames.
#   Default: artifactory
#
#
# === Examples
#
# * Installation:
#     class { 'artifactory': }
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
class artifactory(
  $serverAlias = 'artifactory'
) {

  package { 'artifactory':
    ensure => latest;
  }

  service { 'artifactory':
    ensure  => running,
    enable  => true,
    require => Package['artifactory'];
  }

  file {
    '/data/artifactory_data':
      ensure  => directory,
      mode    => 0775,
      owner   => artifactory,
      group   => artifactory;

    '/data/artifactory_backups':
      ensure  => directory,
      mode    => 0775,
      owner   => artifactory,
      group   => artifactory;

    '/var/lib/artifactory/data':
      ensure  => link,
      target  => '/data/artifactory_data',
      before  => Service['artifactory'],
      require => Package['artifactory'];

    '/opt/artifactory/tomcat/conf/server.xml':
      ensure  => file,
      owner   => artifactory,
      group   => artifactory,
      mode    => 0444,
      source  => 'puppet:///modules/artifactory/server.xml',
      notify  => Service['artifactory'],
      require => Package['artifactory'];
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

# TODO - manage my logs
