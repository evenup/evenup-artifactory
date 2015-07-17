# What is it?

A puppet module that installs artifactory and manages the service.
Configuration of artifactory is mainly done through the app.  A define is
also provided that will fetch artifacts from the repository aideing in
application deployments.

Note: Java is required for this module but I didn't add it to the Modulefile
as a dependency since there are so many indivudalized java deployments.

Backups are done through the backup rubygem.


## Usage:

You can install artifactory using two different methods: The RPM method using packages and the OS' package management system, or using a docker image. The latter will install docker on the host, pull a docker image (the official one or a one by your choosing), and embed the image  in a useful way. Please see also DOCKER NOTES further down.

<pre>
  class { 'artifactory': }

  class { 'artifactory': install_type => 'docker' }
</pre>

Fetching an artifact:
<pre>
  artifactory::fetch_artifact { 'mywar':
    project       => 'myproject',
    version       => '1.2.3',
    format        => 'war',
    install_path  => '/data/tomcat/site',
    filename      => 'myproject-1.2.3-war'
  }
</pre>
This will fetch a war of version 1.2.3 of myproject and store it as
/data/tomcat/site/myproject-1.2.3-war.


### Full reference with default values

... except for the `db_*` part - those default values can be seen in the `artifactory::db` class.

```
class { 'artifactory':
  $ensure           = 'latest',
  $package_provider = undef,
  $package_source   = undef,
  $ajp_port         = 8019,
  $data_path        = $::artifactory::params::std_data_path,
  $backup_path      = undef,
  $install_type     = 'package',
  $docker_img       = 'oss',
  $docker_run_prms  = {},

  # for database config. for defaults see ...::db class.
  $configure_db     = false,    # defaults, if in doubt see artifactory::db
  $db_type          = undef,
  $db_host          = undef,    # 'localhost'
  $db_port          = undef,    # auto-calculated
  $db_user          = undef,    # 'artifactory'
  $db_user_password = undef,
  $db_name          = undef,    # 'artifactory'
  $db_driver_jdbc   = undef,

  # manually specify db settings (only for configure_db => true)
  $db_url           = undef,
  $db_driver        = undef,
}
```

## Docker installation notes

When installed as a docker container, currently the module depends on a modified docker image, because mounting the artifactory `$ARTIFACTORY_HOME/etc` directory does not work with the original image. The buildfile to create the modified container is in the `contrib/docker` directory.

When using the docker image, the artifactory data directories /in/ the container will be mounted on the parent host (*not* in another docker container!). The reason for this is to be able to switch to a HA scenario, where multiple artifactory instances share the same data located on an NFS share. This is not possible with docker volume mounts.

The mount point can be configured using the `artifactory::params` class, and is by default `/var/docker-artifactory`.

... below which the following mounts will be set up for the container:

| (on host)                        | (in container)             |
| -------------------------------- | -------------------------- |
| `/var/docker-artifactory/data`   | `$ARTIFACTORY_HOME/data`   |
| `/var/docker-artifactory/logs`   | `$ARTIFACTORY_HOME/logs`   |
| `/var/docker-artifactory/backup` | `$ARTIFACTORY_HOME/backup` |
| `/var/docker-artifactory/etc`    | `$ARTIFACTORY_HOME/etc`    |


## Database configuration

Artifactory can run with different database configurations. Those can be configured using the artifactory module:

```
# example configuration. The parameters have useful default values if not set.
class { 'artifactory':
  configure_db      => true,
  db_type           => 'postgresql',
  db_host           => 'my_database_host.mynet.com',
  db_user_password  => 'heyho',

  # that has to be downloaded, see http://is.gd/C7gnC4
  db_driver_jdbc    => '/opt/jdbc/postgresql_driver.jar'
}
```

* This works for both installation types, docker and package.
* The only tested database is postgresql right now. The others should work, except for Oracle, which will most probably not work.
* For `db_driver_jdbc`: This is optional, although you need one for every database configuration which is not the embedded derby one. If it is specified puppet will not start the server if it cannot be found. If it is not specified puppet will start artifactory, but artifactory will exit. This will likely become mandatory in the future because the current setup does not make much sense.


## Known Issues:

Only tested on CentOS 6 (package) and CentOS 7 (docker).

## TODO:

* [ ] Make backups optional
* [ ] Make vhost optional
* [ ] Add more configurability
* [ ] Verify against artifactory 3


## License:

Released under the Apache 2.0 licence


## Contribute:

* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR
