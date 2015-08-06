#
#
# == Class: artifactory::config
#
# Class for configuration common to package and docker installation types.
#
#
class artifactory::config {

  # general configuration file directory

  file { '/etc/artifactory':
    ensure  => 'directory',
  }


  # license configuration - placed in /etc/artifactory

  $lic_src = $::artifactory::license_source
  $lic_cnt = $::artifactory::license_content

  if $lic_src != undef or $lic_cnt != undef {
    file { '/etc/artifactory/artifactory.lic':
      ensure  => 'present',
      content => $lic_cnt,
      source  => $lic_src,
      tag     => 'artifactory_config_file',
    }
  }


  # HA config

  if $::artifactory::ha_setup == true {

    $basedir = $::artifactory::ha_cluster_home


    # ha-node.properties - placed in $CLUSTER_HOME

    $context_url = $::artifactory::ha_context_url
    $haprops = "${basedir}/ha-node.properties.${::fqdn}"
    file { $haprops:
      ensure  => 'present',
      content => template("artifactory/ha-node.properties.erb"),
      tag     => 'artifactory_config_file',
    }


    # cluster.properties - placed in $CLUSTER_HOME/ha-etc

    file { "${basedir}/ha-etc/cluster.properties":
      ensure  => 'present',
      content => "security.token=${::artifactory::ha_security_token}\n",
      tag     => 'artifactory_config_file',
    }

  }

}
