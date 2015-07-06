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

  $basedir = '/var/docker-artifactory'

  # this is always the same for docker based mounts
  # format: LOCAL_DIR : DIR_IN_CONTAINER
  $volume_mounts = [
    "${basedir}/data:${::artifactory::params::std_data_path}",
    "${basedir}/logs:${::artifactory::params::std_logs_path}",
    "${basedir}/backup:${::artifactory::params::std_backup_path}",
    "${basedir}/etc:${::artifactory::params::std_etc_path}",
  ]

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

  # requires the master branch of garethr/docker to work properly on redhat
  # systems (actually to use systemd integration on redhat systems)
  docker::run { $use_image:
    image             => $use_image,
    ports             => [ '80:80', '8081:8081', '443:443', '5001:5001', '5002:5002', ],
    volumes           => $volume_mounts,
    extra_parameters  => ['--restart=always'],
    tag               => 'artifactory_service',
  }

}
