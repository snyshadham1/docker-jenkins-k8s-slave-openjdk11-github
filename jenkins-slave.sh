#!/bin/bash

# Usage jenkins-slave.sh [options] -url http://jenkins SECRET SLAVE_NAME

sudo http_proxy=public0-proxy1-0-prd.data.sfdc.net:8080 https_proxy=public0-proxy1-0-prd.data.sfdc.net:8080 no_proxy=127.0.0.1,localhost,.salesforce.com,.data.com,.sfdc.net,.force.com,.docker.io,docker-registry.releng.demandware.net,.sfdcsb.net /usr/bin/dockerd -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock &

sleep 5

# if `docker run` has 2 or more arguments the user is passing jenkins launcher arguments
if [[ $# -gt 1 ]]; then

  # jenkins slave
  JAR=`ls -1 /usr/share/jenkins/remoting-*.jar | tail -n 1`

  PARAMS=""

  # if -url is not provided try env vars
  if [[ "$@" != *"-url "* ]]; then
    if [ ! -z "$JENKINS_URL" ]; then
      PARAMS="$PARAMS -url $JENKINS_URL"
    elif [ ! -z "$JENKINS_SERVICE_HOST" ] && [ ! -z "$JENKINS_SERVICE_PORT" ]; then
      PARAMS="$PARAMS -url http://$JENKINS_SERVICE_HOST:$JENKINS_SERVICE_PORT"
    fi
  fi

  # if -tunnel is not provided try env vars
  if [[ "$@" != *"-tunnel "* ]]; then
    if [ ! -z "$JENKINS_TUNNEL" ]; then
      PARAMS="$PARAMS -tunnel $JENKINS_TUNNEL"
    elif [ ! -z "$JENKINS_SLAVE_SERVICE_HOST" ] && [ ! -z "$JENKINS_SLAVE_SERVICE_PORT" ]; then
      PARAMS="$PARAMS -tunnel $JENKINS_SLAVE_SERVICE_HOST:$JENKINS_SLAVE_SERVICE_PORT"
    fi
  fi

  echo Running java $JAVA_OPTS -cp $JAR hudson.remoting.jnlp.Main -headless $PARAMS "$@"
  exec java $JAVA_OPTS -cp $JAR hudson.remoting.jnlp.Main -headless $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
