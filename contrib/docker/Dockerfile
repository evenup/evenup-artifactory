FROM jfrog-docker-registry.bintray.io/artifactory/artifactory-pro

MAINTAINER Axel Bock <axel.bock@amadeus.com>

# modified init script, which does ...
#   1. made the startup wait period configurable using the environment
#      variable $STARTUP_WAIT_SECS
#   2. takes care that the $ARTIFACTORY_HOME/etc directory is properly
#      filled (which it is not if it is volume-mounted)

# remove the symbolic link, otherwise the TARGET of the symbolic link will
# be mounted, which is _not_ what we want.
RUN rm -f /var/opt/jfrog/artifactory/etc ; mkdir /var/opt/jfrog/artifactory/etc

# yes, without .sh in the container.
COPY data/etc_init.d_artifactory.sh /etc/init.d/artifactory

CMD /tmp/runArtifactory.sh
