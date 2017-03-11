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
  $ensure             = 'latest',
  $package_name       = 'artifactory',
  $service_name       = 'artifactory',
  $package_provider   = undef,
  $package_source     = undef,
  $ajp_port           = 8019,
  $home_dir           = '/var/opt/jfrog/artifactory',
  $data_path          = "/var/opt/jfrog/artifactory/data",
  $backup_path        = undef,
  $db_type            = 'derby',
  $db_host            = 'localhost',
  $db_name            = 'artifactory',
  $db_user            = 'artifactory',
  $db_pass            = undef,
  $license            = undef,
  $config_import_xml  = undef,
  $server_xml         = undef,
  $replica_user       = undef,
  $replica_pass       = undef,
) {

    #requires Java >1.8!!!
  class { '::java':
    package => 'openjdk-8-jre'
  }

  class { '::artifactory::install': }
  class { '::artifactory::config': }
  class { '::artifactory::service': }

}
