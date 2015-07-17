#
#
# == Class: artifactory::ha::mount_nfs_file_storage
#
# Mounts the NFS storage for the files to be stored. The NFS mount comes from
# storeconfigs (to be precise from the class 'file_storage_server', which can
# be used on the NFS server side to export that into puppet).
#
#
class artifactory::ha::mount_file_storage inherits ::artifactory::params {

  include ::nfs::client

  ::Nfs::Client::Mount <<| nfstag == 'artifactory_nfs_export' |>> ~>
  ::Docker::Run <| tag == 'artifactory_service' |> ~>
  ::Service <| name == 'artifactory' |>

}
