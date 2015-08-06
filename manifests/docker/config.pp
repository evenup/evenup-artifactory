#
#
# == Class: artifactory::docker::config
#
# Configures artifactory when using a docker installation.
#
# Usually it does nothing. For HA installation types, it does ...
#
#  * create a $ARTIFACTORY_HOME/ha-node.properties file
#  * create a $CLUSTER_HOME/ha-etc/cluster.properties file
#
#
class artifactory::docker::config {

}
