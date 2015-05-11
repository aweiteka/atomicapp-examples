#!/bin/sh

set -x

# Inherits script from pulp-base: /configure_pulp_server.sh
#
# Requires environment variables:
#
#   PULP_SERVER_NAME
#
#   DB_SERVICE_HOST
#   DB_SERVICE_PORT
#
#   MSG_SERVICE_HOST
#   MSG_SERVICE_PORT
#   MSG_SERVICE_USER
#

WORKER_NUMBER=$1

if [ -z ${WORKER_NUMBER} ]
then
  echo "Missing required argument: worker number"
  exit 2
fi

#
# Use the test_db_available.py script to poll for the DB server
#
wait_for_database() {
    DB_TEST_TRIES=12
    DB_TEST_POLLRATE=5
    TRY=0
    while [ $TRY -lt $DB_TEST_TRIES ] && ! /test_db_available.py 
    do
	TRY=$(($TRY + 1))
	echo "Try #${TRY}: DB unavailable - sleeping ${DB_TEST_POLLRATE}"
	sleep $DB_TEST_POLLRATE
    done
    if [ $TRY -ge $DB_TEST_TRIES ]
    then
	echo "Unable to contact DB after $TRY tries: aborting container"
        exit 2
    fi
}

run_worker() {
  # WORKER_NUMBER=$1
  exec runuser apache \
    -s /bin/bash \
    -c "/usr/bin/celery worker \
    --events --app=pulp.server.async.app \
    --loglevel=INFO \
    -c 1 \
    --umask=18 \
    -n reserved_resource_worker-$1@$PULP_SERVER_NAME \
    --logfile=/var/log/pulp/reserved_resource_worker-$1.log"
}

# =============================================================================
# Main
# =============================================================================
#

#
# First, initialize the pulp server configuration
#
if [ ! -x /configure_pulp_server.sh ]
then
  echo >&2 "Missing required initialization script for pulp server: /configure_pulp_server.sh"
  exit 2
fi
. /configure_pulp_server.sh

if [ ! -x /test_db_available.py ] 
then
  echo >&2 "Missing required initialization script for pulp server: /test_db_available.py"
  exit 2
fi
wait_for_database

#
# The celery worker for the Pulp Resource Manager
#
run_worker $WORKER_NUMBER
