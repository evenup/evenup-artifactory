#
#
# == Class: artifactory::params
#
# The params class of the artifactory module.
#
#
class artifactory::params (
    $artifactory_base       = '/var/opt/jfrog/artifactory',
    $docker_oss_img_src     = 'jfrog-docker-registry.bintray.io/artifactory/artifactory-oss',
    $docker_pro_img_src     = 'jfrog-docker-registry.bintray.io/artifactory/artifactory-pro',
    $docker_mount_base      = '/var/docker-artifactory',
) {

    $std_user_home    = $artifactory_base

    $std_etc_path     = "${artifactory_base}/etc"
    $std_data_path    = "${artifactory_base}/data"
    $std_logs_path    = "${artifactory_base}/logs"
    $std_backup_path  = "${artifactory_base}/backup"

}
