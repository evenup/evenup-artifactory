# == Definition: artifactory::fetch_artifact
#
# This define fetches a specific artifact from artifactory
#
# === Parameters
#
# [*project*]
#   String.  The name of the artifactory project
#
# [*version*]
#   String.  Which version to fetch
#
# [*format*]
#   String.  What format of the artifact to fetch.
#   Default: ''
#
# [*install_path*]
#   String.  Where should the fetched file be installed at
#
# [*path*]
#   String.  Additional path needed to locate the artifact
#   Default: empty
#
# [*server*]
#   String.  Name (and protocol) of the artifactory server
#   Default: http://artifactory
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
#
# === Examples
#
#   artifactory::fetch_artifact { 'mywar':
#     project       => 'myproject',
#     version       => '1.2.3',
#     format        => 'war',
#     install_path  => '/data/tomcat/site',
#     filename      => 'myproject-1.2.3-war'
#   }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define artifactory::fetch_artifact (
  $project,
  $version,
  $install_path,
  $format,
  $path        = undef,
  $server      = 'http://artifactory',
  $repo        = 'libs-release-local',
  $filename    = undef,
  $source_file = undef,
){

  if $source_file {
    $sourcefile_real = $source_file
  } else {
    $sourcefile_real = "${project}-${version}.${format}"
  }

  if $filename {
    $filename_real = $filename
  } else {
    $filename_real = "${project}-${version}.${format}"
  }

  if ( $path ) {
    $fetch_url = "${server}/artifactory/${repo}/${path}/${project}/${version}/${sourcefile_real}"
  } else {
    $fetch_url = "${server}/artifactory/${repo}/${project}/${version}/${sourcefile_real}"
  }

  $full_path = "${install_path}/${filename_real}"

  exec { "artifactory_fetch_${name}":
    command   => "curl -o ${full_path} ${fetch_url}",
    cwd       => $install_path,
    creates   => $full_path,
    path      => '/usr/bin:/bin',
    logoutput => on_failure;
  }
}
