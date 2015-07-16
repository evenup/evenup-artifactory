#
#
# == Class: artifactory::docker::service
#
# Installs the artifactory service
#
#
class artifactory::docker::service inherits artifactory::params {

  $use_image = $::artifactory::docker_img ? {
    'oss'   => $::artifactory::params::docker_oss_img_src,
    'pro'   => $::artifactory::params::docker_pro_img_src,
    default => $::artifactory::docker_img,
  }

  $basedir = $::artifactory::params::docker_mount_base

  # this is always the same for docker based mounts
  # format: LOCAL_DIR : DIR_IN_CONTAINER
  $volume_mounts = [
    "${basedir}/data:${::artifactory::params::std_data_path}",
    "${basedir}/logs:${::artifactory::params::std_logs_path}",
    "${basedir}/backup:${::artifactory::params::std_backup_path}",
    "${basedir}/etc:${::artifactory::params::std_etc_path}",
  ]

  if $::artifactory::configure_db {
    # it's always "on_host:in_container"
    $driver_file_host = $::artifactory::db::db_driver_jdbc
    $driver_file_name = basename($driver_file_host)
    $driver_file_dckr = "${::artifactory::params::artifactory_base}/tomcat/lib/${driver_file_name}"

    $use_volume_mounts = concat($volume_mounts,
      [
        "${driver_file_host}:${driver_file_dckr}",
      ])

  } else {
    $use_volume_mounts = $volume_mounts
  }


  file { $basedir:
    ensure  => 'directory',
  }

  file {
    [
      "${basedir}/data",
      "${basedir}/logs",
      "${basedir}/backup",
      "${basedir}/etc",
    ]:
    ensure  => 'directory',
    mode    => '0777',
  } ->

  File <| tag == 'artifactory_config_file' |> ~>
  ::Docker::Run<| tag == 'artifactory_service' |>

  # requires the master branch of garethr/docker to work properly on redhat
  # systems (actually to use systemd integration on redhat systems)
  $runme = {
    'artifactory_service' => {
      'image'             => $use_image,
      'ports'             => [ '80:80', '8081:8081', '443:443', '5001:5001', '5002:5002', ],
      'volumes'           => $use_volume_mounts,
      'tag'               => 'artifactory_service',
    }
  }

  create_resources('::docker::run', $runme, $::artifactory::docker_run_prms)

}
