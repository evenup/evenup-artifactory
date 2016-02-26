# == Definition: artifactory::fetch_artifact_generic
#
# This define fetches a specific artifact from artifactory
#
# === Parameters
#
# [*install_path*]
#   String.  Where should the fetched file be installed at
#
# [*base_path*]
#   String.  Full path to artifactory repository
#   Default: 'http://artifactory/artifactory'
#
# [*repo*]
#   String.  Name of the repository that holds this artifact
#   Default: libs-release-local
#
# [*filename*]
#   String.  Filename that should be used for the fetched file
#   Default: $project-$version.$format
#
# [*source_file*]
#   String.  Source file name in project
#   Default: ''
#
# [*layout]
#   Path to fetch file inside arifactory
#
# === Examples
#
#   artifactory::fetch_artifact { 'mywar':
#     install_path  => '/data/tomcat/site',
#     base_path     => 'http://myhost/myartifactory',
#     repo          => 'mysimplerepo',
#     filename      => 'myproject-1.2.3.war',
#     source_file   => 'myproject.war',
#     layout        => 'myteam/myproject/1.2.3/foo'
#   }
#
#
# === Authors
#
# * Artem Popenkov <mailto:artem.popenkov@concur.com>
#
define artifactory::fetch_artifact_generic(
  $install_path,
  $base_path   = 'http://artifactory/artifactory',
  $repo        = 'libs-release-local',
  $filename    = '',
  $source_file,
  $layout,
){

  if ( $source_file == '') {
    fail('source_file is required')
  }

# Use source file if filename is not specified
  $filename_real = $filename ? {
    ''      => $source_file,
    default => $filename
  }

  $fetch_url = "${base_path}/${repo}/${layout}/${source_file}"
  $full_path = "${install_path}/${filename_real}"

  $logoutput = on_failure

  case $osfamily {
    windows: {
      $command = "Import-Module BitsTransfer; Start-BitsTransfer -Source ${fetch_url} -Destination ${install_path}"
      $provider = powershell
      $path = ''
    }
    default:{
      $command = "curl -o ${full_path} ${fetch_url}"
      $provider = shell
      $path = '/usr/bin:/bin'
    }
  }

  exec{"artifactory_fetch_${name}":
    command => $command,
    cwd       => $install_path,
    creates => $full_path,
    provider => $provider,
    path => $path,
    logoutput => $logoutput,
  }
}