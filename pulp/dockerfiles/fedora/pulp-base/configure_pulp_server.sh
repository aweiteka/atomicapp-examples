#!/bin/sh

set -x

# Take settings from Kubernetes service environment unless they are explicitly
# provided
PULP_SERVER_CONF=${PULP_SERVER_CONF:=/etc/pulp/server.conf}
export PULP_SERVER_CONF

#PULP_SERVER_NAME=${PULP_SERVER_NAME:=pulp.example.com}
#export PULP_SERVER_NAME

#DB_SERVICE_HOST=${DB_SERVICE_HOST:UNSET}
PULP_DB_SERVICE_PORT=${PULP_DB_SERVICE_PORT:=27017}
export PULP_DB_SERVICE_PORT

#MSG_SERVICE_HOST=${PULP_MSG_SERVICE_HOST:=UNSET}
PULP_MSG_SERVICE_PORT=${PULP_MSG_SERVICE_PORT:=5672}
PULP_MSG_SERVICE_USER=${PULP_MSG_SERVICE_USER:=guest}
export PULP_MSG_SERVICE_PORT PULP_MSG_SERVICE_NAME

ERRORS=0

check_config_target() {
    if [ ! -f ${PULP_SERVER_CONF} ]
    then
        echo "Cannot find required config file ${PULP_SERVER_CONF}"
	ERRORS=$(($ERRORS + 1))
    fi
}

#
# Set the Pulp service public hostname
#
configure_server_name() {
    if [ -z "$PULP_SERVER_NAME" ]
    then
	echo "Missing equired value for PULP_SERVER_NAME"
	ERRORS=$((ERRORS + 1))
	return
    fi
    augtool -s set \
       "/files/etc/pulp/server.conf/target[. = 'server']/server_name" \
       "${PULP_SERVER_NAME}"
}

#
# Set the messaging server access information
#
configure_messaging() {
    if [ -z "$PULP_MSG_SERVICE_HOST" ]
    then
	echo "Missing required value for PULP_MSG_SERVICE_HOST"
	ERRORS=$((ERRORS + 1))
	return
    fi

    augtool -s set "/files/etc/pulp/server.conf/target[. = 'messaging']/url" \
	"tcp://${PULP_MSG_SERVICE_HOST}:${PULP_MSG_SERVICE_PORT}"
    augtool -s set \
	"/files/etc/pulp/server.conf/target[. = 'tasks']/broker_url" \
	"qpid://${PULP_MSG_SERVICE_USER}@${PULP_MSG_SERVICE_HOST}:${PULP_MSG_SERVICE_PORT}"
}

#
# Set the database access information
#
configure_database() {
    if [ -z "$PULP_DB_SERVICE_HOST" ]
    then
	echo "Missing required value for PULP_DB_SERVICE_HOST"
	ERRORS=$((ERRORS + 1))
	return
    fi

    augtool -s set \
	"/files/etc/pulp/server.conf/target[. = 'database']/seeds" \
	"${PULP_DB_SERVICE_HOST}:${PULP_DB_SERVICE_PORT}"
}

# =============================================================================
# Main
# =============================================================================
check_config_target

configure_server_name
configure_database
configure_messaging

if [ $ERRORS -ne 0 ]
then
    echo "${0}: there were ${ERRORS} errors in setup: aborting"
    exit 2
fi
