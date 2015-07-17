#
#
# == Class: artifactory::docker::install
#
# Installs artifactory as a docker container.
#
# == Requirements
#
# * garethr/docker
#
#
class artifactory::docker::install {

  include docker

  $img_type = $::artifactory::docker_img

  $use_image = $img_type ? {
    'oss'   => $::artifactory::params::docker_oss_img_src,
    'pro'   => $::artifactory::params::docker_pro_img_src,
    default => $img_type,
  }

  $version = $::artifactory::ensure
  $use_tag = $version ? {
    'latest'  => undef,
    default   => $version,
  }

  docker::image { 'artifactory':
    image     => $use_image,
    image_tag => $use_tag,
  }

}
