# == Class: artifactory::config
#
# This class configures artifactory.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class artifactory::config (
  $ajp_port = $::artifactory::ajp_port,
  $db_type  = downcase($::artifactory::db_type),
  $db_host  = $::artifactory::db_host,
  $db_name  = $::artifactory::db_name,
  $db_user  = $::artifactory::db_user,
  $db_pass  = $::artifactory::db_pass,
){

  if downcase($::artifactory::db_type) != 'derby' {
    file {"${::artifactory::home_dir}/etc":
      ensure => directory,
      owner  => artifactory,
      group  => artifactory,
    }
  }

  if $::artifactory::db_type == 'postgresql' {
    file {"${::artifactory::home_dir}/etc/db.properties":
      ensure  => file,
      path    => "${::artifactory::home_dir}/etc/storage.properties",
      content => template('artifactory/storage.properties.pg.erb'),
      notify  => Class['artifactory::service'],
      owner   => artifactory,
      group   => artifactory,
    }
  }

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::artifactory::config_import_xml {
    file   {   "${::artifactory::home_dir}/etc/artifactory.config.import.xml":
      ensure  =>   file,
      content =>   $::artifactory::config_import_xml,
      owner   =>   artifactory,
      group   =>   artifactory,
    }
  }

  if $::artifactory::server_xml {
    file  {  "${::artifactory::home_dir}/tomcat/conf/server.xml":
        ensure    =>  file,
        owner      =>  artifactory,
        group      =>  artifactory,
        mode        =>  '0444',
        content  =>  $::artifactory::server_xml,
        notify    =>  Class['artifactory::service'],
    }
  }

  if $::artifactory::license {
    file { "${::artifactory::home_dir}/etc/artifactory.lic":
      content => $::artifactory::license,
      notify  => Service['artifactory'],
      owner   => 'artifactory',
      group   => 'artifactory',
      require => [ User['artifactory'], Group['artifactory'], File[$::artifactory::data_path] ]
    }
  }
}
