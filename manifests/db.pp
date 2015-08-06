#
#
# == Class: artifactory::db
#
# Configures the database artifactory uses
#
# NOTE: No idea where the database name in "oracle" is found. This has to be
# checked and most probably adjusted. I don't think this is working.
#
#
class artifactory::db (
  $db_type,
  $db_host              = 'localhost',
  $db_port              = undef,
  $db_name              = 'artifactory',
  $db_user              = 'artifactory',
  $db_user_password     = '',

  # or manually orverride everything ...
  $db_url               = undef,
  $db_driver            = undef,

  # required in 99.9% of all cases :)
  $db_driver_jdbc       = undef,    # must be a file system path

) {

  $valid_db_types = 'postgresql|mssql|mysql|oracle'
  validate_re($db_type, "^(${valid_db_types})\$",
    "Unsupported db type '${db_type}': must be one of '${valid_db_types}'")

  $inst_type = $::artifactory::install_type
  $ha_setup  = $::artifactory::ha_setup


  if $db_port != undef {
    $use_db_port = $db_port
  } else {
    $use_db_port = $db_type ? {
      'postgresql'  => '5432',
      'mysql'       => '3306',
      'mssql'       => '1433',
      'oracle'      => '1521',
    }
  }

  if $db_url != undef {
    $use_db_url = $db_url
  } else {
    $use_db_url = $db_type ? {
      'postgresql'  => "jdbc:postgresql://${db_host}:${use_db_port}/${db_name}",
      'mysql'       => "jdbc:mysql://${db_host}:${use_db_port}/${db_name}?characterEncoding=UTF-8&elideSetAutoCommits=true",
      'mssql'       => "jdbc:sqlserver://${db_host}:${use_db_port};databaseName=${db_name};sendStringParametersAsUnicode=false;applicationName=Artifactory Binary Repository",
      'oracle'      => "jdbc:oracle:thin:@${db_host}:${use_db_port}:ORCL",
    }
  }

  if $db_driver != undef {
    $use_db_driver = $db_driver
  } else {
    $use_db_driver = $db_type ? {
      'postgresql'  => 'org.postgresql.Driver',
      'mysql'       => 'com.mysql.jdbc.Driver',
      'mssql'       => 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
      'oracle'      => 'oracle.jdbc.OracleDriver',
    }
  }

  if $db_driver_jdbc != undef {
    $check_exec_title = "jdbc driver file not found: '${db_driver_jdbc}'"
    File <| tag == 'artifactory_config_file' |> ->
    exec { $check_exec_title:
      command => 'bash -c false',
      unless  => "test -f '${db_driver_jdbc}'",
      path    => '/bin:/usr/bin',
    }
    Exec[$check_exec_title] ->
    ::Docker::Run <| tag == 'artifactory_service' |>
    if $inst_type == 'package' {
      $drv_path = "${::artifactory::params::artifactory_base}/tomcat/lib"
      $drv_name = basename($db_driver_jdbc)
      exec { 'copy jdbc driver file':
        command => "cp '${db_driver_jdbc}' '${drv_path}'",
        unless  => "test -f '${drv_path}/${drv_name}'",
        path    => '/usr/bin:/bin',
        require => Exec[$check_exec_title],
      } ~>
      Service <| tag == 'artifactory_service' |>
    }
  }


  $cfg_file = $ha_setup ? {
    true    => "${::artifactory::ha_cluster_home}/ha-etc/storage.properties",
    default => $inst_type ? {
      'package' => "${::artifactory::params::std_etc_path}/storage.properties",
      'docker'  => "${::artifactory::ha_cluster_home}/etc/storage.properties",
    }
  }

  # normal permissions _should_ be 0644. If we set permissions and the
  # artifactory init script adjusts them again we have artifactory restarts
  # all the time.
  file { $cfg_file:
      ensure  => 'present',
      content => template('artifactory/database.properties.erb'),
      tag     => 'artifactory_config_file',
  }

}
