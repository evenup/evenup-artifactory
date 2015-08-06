#
#
# == Class: artifactory::ha::file_storage_server
#
# configures this host to export an NFS mount to the artifactory server
# instances.
#
#
# === Parameters
#
# [*file_storage_path*]
#   String. Default: /srv/artifactory_files.
#   Where the files are stored on the server, basically which directory to
#   export.
#
# [*storage_perms*]
#   String. Default: 0777.
#   Directory permissions of $file_storage_path.
#
# [*storage_use*]
#   String. No default.
#   Which user should own $file_storage_path
#
# [*storage_group*]
#   String. No default.
#   Which group should own $file_storage_path
#
# [*allow_clients*]
#   String. Default: '*'
#   In /etc/exports: the client part of the exports entry.
#
# [*client_opts*]
#   String (comma-separated values). Always included: rw,root_squash
#   The options for the client. Will be connected to the default options to
#   form the exports entry: '$allow_clients(rw,root_squash[,$client_opts])'
#
class artifactory::ha::file_storage_server (
  $file_storage_path = '/srv/artifactory_files',
  $storage_perms = '0777',
  $storage_user  = undef,
  $storage_group = undef,
  $allow_clients = '*',
  $client_opts   = undef,
) {

  include ::nfs::server

  $default_exports_opts = 'rw,root_squash'
  $use_client_opts = $client_opts ? {
    undef   => $default_exports_opts,
    default => "${default_exports_opts},${client_opts}"
  }

  exec { "mkdir -p \"${file_storage_path}\"":
    path   => '/usr/bin:/bin',
    unless => "test -d \"${file_storage_path}\"",
  } ->

  file { $file_storage_path:
    ensure => 'directory',
    mode   => $storage_perms,
    owner  => $storage_user,
    group  => $storage_group,
  } ->

  ::nfs::server::export { $file_storage_path:
    ensure  => 'mounted',
    atboot  => true,
    options => '_netdev,rw',
    clients => "${allow_clients}(${use_client_opts})",
    nfstag  => 'artifactory_nfs_export',
  }

}
