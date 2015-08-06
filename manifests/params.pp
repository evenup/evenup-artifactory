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
    $mount_base             = '/var/artifactory',
) {

    $std_user_home    = $artifactory_base

    $std_etc_path     = "${artifactory_base}/etc"
    $std_data_path    = "${artifactory_base}/data"
    $std_logs_path    = "${artifactory_base}/logs"
    $std_backup_path  = "${artifactory_base}/backup"

    $std_context_url  = "http://${::ipaddress}:8081/artifactory"

}
