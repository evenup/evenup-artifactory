# == Class: artifactory::package::config
#
# This class configures artifactory.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class artifactory::package::config (
  $ajp_port = $::artifactory::ajp_port,
){

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include ::java

  file { '/opt/jfrog/artifactory/tomcat/conf/server.xml':
    ensure  => file,
    owner   => artifactory,
    group   => artifactory,
    mode    => '0444',
    content => template('artifactory/server.xml.erb'),
    notify  => Class['artifactory::package::service'],
  }


  # license

  if defined(File['/etc/artifactory/artifactory.lic']) {

    file { "${::artifactory::params::std_etc_path}/artifactory.lic":
      ensure  => 'link',
      target  => '/etc/artifactory/artifactory.lic',
      tag     => 'artifactory_config_file',
    }

  }


  # HA config

  if $::artifactory::ha_setup == true {

    # link to ha-node.properties.FQDN in /etc/artifactory
    file { "${::artifactory::params::std_etc_path}/ha-node.properties":
      ensure  => 'link',
      target  => $::artifactory::config::haprops,
      tag     => 'artifactory_config_file',
      require => File[$::artifactory::config::haprops],
    }

  }

}
