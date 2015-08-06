#
#
# == Class: artifactory::install
#
# Class for installation common to package and docker installation types.
#
#
class artifactory::install {

  $basedir      = $::artifactory::ha_cluster_home
  $create_dirs  = [
    'etc',
    'data',
    'backup'
  ]

  if $::artifactory::ha_setup == true {
    $use_create_dirs = prefix($create_dirs, "${basedir}/ha-")
  } elsif $::artifactory::install_type == 'docker' {
    $use_create_dirs = prefix($create_dirs, "${basedir}/")
  } else {
    $use_create_dirs = []
  }

  if size($use_create_dirs) > 0 {
    file { $basedir:
      ensure  => 'directory',
    }
    file { $use_create_dirs:
      ensure => 'directory',
      mode   => '0777',
    }
  }

}
