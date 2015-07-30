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

  $lic_file     = '/etc/artifactory/artifactory.lic'

  $hostbase     = $::artifactory::ha_cluster_home

  $cont_art     = $::artifactory::params::artifactory_base
  $cont_etc     = $::artifactory::params::std_etc_path
  $cont_logs    = $::artifactory::params::std_logs_path
  $cont_data    = $::artifactory::params::std_data_path
  $cont_backup  = $::artifactory::params::std_backup_path


  # this is always the same for docker based mounts
  # format: LOCAL_DIR : DIR_IN_CONTAINER
  $volume_mounts_base = $::artifactory::ha_setup ? {
    true    => [
      "${hostbase}:/ha",
      "${hostbase}/ha-node.properties.${::fqdn}:${cont_etc}/ha-node.properties",
    ],
    default => [
      "${hostbase}/data:${cont_data}",
      "${hostbase}/logs:${cont_logs}",
      "${hostbase}/backup:${cont_backup}",
      "${hostbase}/etc:${cont_etc}",
    ],
  }


  if $::artifactory::configure_db and $::artifactory::db::db_driver_jdbc != undef {
    # it's always "on_host:in_container"
    $driver_file_host = $::artifactory::db::db_driver_jdbc
    $driver_file_name = basename($driver_file_host)
    $driver_file_dckr = "${cont_art}/tomcat/lib/${driver_file_name}"
    $vm_with_db = concat($volume_mounts_base,
      [
        "${driver_file_host}:${driver_file_dckr}",
      ])

  } else {
    $vm_with_db = $volume_mounts_base
  }


  $vm_with_lic = defined(File[$lic_file]) ? {
    true    => concat($vm_with_db, [ "${lic_file}:${cont_etc}/artifactory.lic" ]),
    default => $vm_with_db,
  }


  $use_volume_mounts = $vm_with_lic


  # start.

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
