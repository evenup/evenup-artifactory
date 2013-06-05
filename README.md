What is it?
===========

A puppet module that installs artifactory and manages the service.
Configuration of artifactory is mainly done through the app.  A define is
also provided that will fetch artifacts from the repository aideing in
application deployments.

Backups are done through the backup rubygem.


Usage:
------

Generic artifactory install
<pre>
  class { 'artifactory':
    serverAlias => [ 'artifactory', 'artifactory.mycompany.com' ]
  }
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


Known Issues:
-------------
Only tested on CentOS 6

TODO:
____
[ ] Make backups optional
[ ] Make vhost optional
[ ] Add more configurability
[ ] Verify against artifactory 3

License:
_______

Released under the Apache 2.0 licence


Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR
