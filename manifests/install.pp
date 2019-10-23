# == Class: artifactory::install
#
# This class installs artifactory.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class artifactory::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::osfamily == 'Debian' {
    apt::key { 'artifactory':
      key        => 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
      key_source => 'https://bintray.com/user/downloadSubjectPublicKey?username=jfrog',
    }

    apt::source { 'artifactory-oss':
      comment     => 'Atifactory open source repository',
      location    => 'https://bintray.com/artifact/download/jfrog/artifactory-debs',
      repos       => 'main',
      include_deb => 'true',
      key         => 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
      key_server  => 'keyserver.ubuntu.com',
    }

    apt::source { 'artifactory-pro':
      comment     => 'Atifactory Pro repository',
      location    => 'https://jfrog.bintray.com/artifactory-pro-debs',
      repos       => 'main',
      include_deb => 'true',
      key         => 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
      key_server  => 'pgp.mit.edu',
    }
  }

  user { 'artifactory':
    ensure => 'present',
    system => true,
    shell  => '/bin/bash',
    home   => $::artifactory::home_dir,
    gid    => 'artifactory',
  }

  group { 'artifactory':
    ensure => 'present',
    system => true,
  }

  package { 'artifactory':
    ensure   => $::artifactory::ensure,
    name     => $::artifactory::package_name,
    provider => $::artifactory::package_provider,
    source   => $::artifactory::package_source,
    notify   => Class['artifactory::service'],
    require  => [ User['artifactory'], Group['artifactory'], Exec['apt_update'] ],
  }

  file {$::artifactory::home_dir:
    require => Package['artifactory'],
    ensure  => directory,
    owner   => artifactory,
    group   => artifactory,
  }

  exec { 'artifactory-home-dir-owner':
    command => "/bin/chown -R -L artifactory:artifactory ${::artifactory::home_dir}",
    require => File[$::artifactory::home_dir],
  }

  if $::artifactory::data_path != "${::artifactory::home_dir}/data" {
    File <| title == $::artifactory::data_path |> {
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    }

    file { "${::artifactory::home_dir}/data":
      ensure => link,
      target => $::artifactory::data_path,
      owner  => artifactory,
      group  => artifactory,
    }
  }

  if $::artifactory::backup_path {
    file { $::artifactory::backup_path:
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    }
  }

  if $::artifactory::db_type == 'postgresql' {
    file { "${::artifactory::home_dir}/tomcat/lib":
      ensure => directory,
      mode   => '0775',
      owner  => artifactory,
      group  => artifactory,
    } ->
    exec { 'Download java postgresql drivrer':
      cwd     => "${::artifactory::home_dir}/tomcat/lib",
      path    => ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin'],
      command => "wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -P ${::artifactory::home_dir}/tomcat/lib/",
      notify  => Service["artifactory"],
      creates => "${::artifactory::home_dir}/tomcat/lib/postgresql-9.4.1212.jar",
    }
  }
}
