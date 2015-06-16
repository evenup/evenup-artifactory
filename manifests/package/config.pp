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

}
