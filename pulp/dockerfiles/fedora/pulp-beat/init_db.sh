#!/bin/sh

set -x

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
    if [ $DB_TEST_TRIES -ne -1 -a $TRY -ge $DB_TEST_TRIES ]
    then
	echo "Unable to contact DB after $TRY tries: aborting container"
        exit 2
    fi
}

#
# Create the initial database for Pulp
#
initialize_database() {
    # why apache? MAL
    echo "Testing Pulp Database Initialization"
    runuser apache -s /bin/bash /bin/bash -c "/usr/bin/pulp-manage-db"
}

database_initialized() {
    echo "Initializing Database for Pulp"
    runuser apache -s /bin/bash /bin/bash -c "/usr/bin/pulp-manage-db --dry-run"
}

# =============================================================================
# Main
# =============================================================================
#

if [ ! -x /test_db_available.py ] 
then
  echo >&2 "Missing required initialization script for pulp server: /test_db_available.py"
  exit 2
fi
wait_for_database

#
# This should only be done once per Pulp service instance.  Since the
# beat server is a singleton, this should work.
#
if ! database_initialized
then
  initialize_database
fi
