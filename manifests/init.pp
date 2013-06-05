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

  class { 'artifactory::install':
    serverAlias => $serverAlias
  }

  class { 'artifactory::config': }

  class { 'artifactory::service': }

  # Containment
  anchor { 'artifactory::begin': }
  anchor { 'artifactory::end': }

  Anchor['artifactory::begin'] ->
  Class['artifactory::install'] ->
  Class['artifactory::config'] ->
  Class['artifactory::service'] ->
  Anchor['artifactory::end']

}
