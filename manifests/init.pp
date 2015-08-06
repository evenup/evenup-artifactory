# == Class: artifactory
#
# This class installs and configures artifactory, apache vhost, and backups.
#
#
# === Parameters
#
# [*ensure*]
#     String.  Version of artifactory to be installed or latest/present
#     Default: 'latest'
#
# [*install_type*]
#   Either 'docker' or 'package'. The first will install docker and run the
#   official artifactory docker image in it, the second will install
#   artifactory using RPMs.
#   Default: 'package'
#
# [*docker_img*]
#   Either 'oss', 'pro' or an actual "fully qualified" docker image path.
#   'oss' will use the official artifactory open source docker image, 'pro'
#   the official enterprise image (for which you need a license). If you
#   provide your own docker image you can just enter the image path here.
#   Default: 'artifactory'
#
# [*docker_run_prms*]
#   A hash which contains additional parameters for ::docker::run in case
#   of the container based installation type.
#   For all default values of the 'db_*' settings see the artifactory::db
#   class.
#   Default: {} (empty hash)
#
# [*configure_db*]
#   Whether to configure the database of artifactory, or to just use the default
#   setings.
#   Default:
#   Default: false
#
# [*db_type*]
#   The database type to use. Options are: mysql,postgresql,mssql,oracle.
#   No default, required if $configure_db == true.
#
# [*db_host*]
#   The host of the database to use.
#   Default: 'localhost'
#
# [*db_port*]
#   The port of the database to use.
#   Default: Depending on the database type selected in $db_type.
#
# [*db_user*]
#   The user name to use to connecto to the database.
#   Default: 'artifactory'
#
# [*db_user_password*]
#   The password for the database user.
#   Default: no default
#
# [*db_name*]
#   The database name to use.
#   Default: 'artifactory'
#
# [*db_driver_jdbc*]
#   Optional, but you really want to set this. Each database needs a JDBC
#   driver to work properly, which does _not_ come with artifactory pre-
#   installed. Please refer to the artifactory documentation of how to
#   download this driver.
#   Once you downloaded this driver, this is the full path (inclding the
#   file name) to the *.jar JDBC driver file on the local file system
#   of the artifactory host.
#   Default: no default
#
# [*db_driver*]
#   The driver string is normally derived from the db_* settings above. In case
#   you want to use your own, set this. The other db_* settings are ignored
#   then.
#   Default: no default
#
# [*db_url*]
#   The database connection url is put together based on the data from the
#   db_* settings above. In case you want to override this manually you
#   set this parameter, the other db_* settings are ignored then.
#   Default: no default
#
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
# * Axel Bock <mailto:mr.axel.bock@gmail.com>
#
class artifactory(
  $ensure                   = 'latest',
  $package_provider         = undef,
  $package_source           = undef,
  $ajp_port                 = 8019,
  $data_path                = $::artifactory::params::std_data_path,
  $backup_path              = undef,
  $install_type             = 'package',
  $docker_img               = 'oss',
  $docker_run_prms          = {},

  # if you have a license, set one of this
  $license_source           = undef,
  $license_content          = undef,

  # do high availability setup
  $ha_setup                 = false,
  $ha_primary_node          = undef,
  $ha_security_token        = undef,
  $ha_membership_port       = 10001,
  $ha_cluster_home          = $::artifactory::params::mount_base,
  $ha_context_url           = $::artifactory::params::std_context_url,

  # for database config. for defaults see ...::db class.
  $configure_db             = false,
  $db_type                  = undef,
  $db_host                  = undef,
  $db_port                  = undef,
  $db_user                  = undef,
  $db_user_password         = undef,
  $db_name                  = undef,
  $db_driver_jdbc           = undef,

  # manually specify db settings (only for configure_db => true)
  $db_url                   = undef,
  $db_driver                = undef,
) inherits artifactory::params {

  validate_re($install_type, '^(package|docker)$',
    "artifactory::install_type must be (package/docker) - not '${install_type}'")

  if $ha_setup and $ha_primary_node == undef {
    fail('artifactory: for $ha_setup you must set $ha_primary_node!')
  }

  if $ha_setup and $ha_security_token == undef {
    fail('artifactory: for $ha_setup you must set $ha_security_token!')
  }

  if $license_source != undef and $license_content != undef {
    fail('artifactory: set ONE of $license_source or $license_content!')
  }

  class { '::artifactory::install': } ->
  class { "::artifactory::${install_type}::install": } ->
  class { '::artifactory::config': } ->
  class { "::artifactory::${install_type}::config":
    before  => Class["::artifactory::${install_type}::service"],
  }

  if $configure_db {
    class { '::artifactory::db':
      db_type          => $db_type,
      db_host          => $db_host,
      db_port          => $db_port,
      db_user          => $db_user,
      db_user_password => $db_user_password,
      db_name          => $db_name,
      db_driver_jdbc   => $db_driver_jdbc,

      db_url           => $db_url,
      db_driver        => $db_driver,
    }
  }

  class { "::artifactory::${install_type}::service": }

}
