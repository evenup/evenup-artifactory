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
# [*docker_img*]
#   Either 'oss', 'pro' or an actual "fully qualified" docker image path.
#   'oss' will use the official artifactory open source docker image, 'pro'
#   the official enterprise image (for which you need a license). If you
#   provide your own docker image you can just enter the image path here.
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
  $package_provider = undef,
  $package_source   = undef,
  $ajp_port         = 8019,
  $data_path        = $::artifactory::params::std_data_path,
  $backup_path      = undef,
  $install_type     = 'package',
  $docker_img       = 'oss',
) inherits artifactory::params {

  validate_re($install_type, '^(package|docker)$',
    "artifactory::install_type must be (package/docker) - not '${install_type}'")

  class { "::artifactory::${install_type}::install": } ->
  class { "::artifactory::${install_type}::config": } ->
  class { "::artifactory::${install_type}::service": }

}
