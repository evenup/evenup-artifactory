# == Class: artifactory
#
# This class installs and configures artifactory, apache vhost, and backups.
#
#
# === Parameters
#
# [*ensure*]
#   String.  Version of artifactory to be installed or latest/present
#   Default: latest
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
class artifactory(
  $ensure           = 'latest',
  $package_name     = 'artifactory',
  $service_name     = 'artifactory',
  $package_provider = undef,
  $package_source   = undef,
  $ajp_port         = 8019,
  $data_path        = '/var/opt/jfrog/artifactory/data',
  $backup_path      = undef,
  $create_data_path = true,
) {

  Class['::java']
  -> Class['::artifactory::install']
  -> Class['::artifactory::config']
  -> Class['::artifactory::service']

  contain '::java'
  contain '::artifactory::install'
  contain '::artifactory::config'
  contain '::artifactory::service'


}
