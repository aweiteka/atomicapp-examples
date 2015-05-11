#!/bin/sh
#
# Configure the Apache daemon and WSGI application
# Install SSL certificates
# Configure the web tree in the volumes
#
set -x

# Requires environment variables:
#
#   DB_SERVICE_HOST
#   DB_SERVICE_PORT
#
#   MSG_SERVICE_HOST
#   MSG_SERVICE_PORT
#   MSG_SERVICE_USER
#
#   PULP_SERVER_NAME
#
#   SSL_TARBALL_URL

#
# Check for minimal input and report missing values
#
if [ -z "$PULP_SERVER_NAME" ]
then
    echo "missing required environment variable PULP_SERVER_NAME"
    exit 2
fi

if [ -z "$SSL_TARBALL_URL" ]
then
    echo "missing environment variable SSL_TARBALL_URL"
    exit 2
fi

#
# Define default variable values
#
TLS_ROOT=/etc/pki/tls
CERT_FILE=${TLS_ROOT}/certs/localhost.crt
KEY_FILE=${TLS_ROOT}/private/localhost.key

HTTPD_CONF=/etc/httpd/conf/httpd.conf
SSL_CONF=/etc/httpd/conf.d/ssl.conf

#
# Define operational functions
#

init_www_tree() {
  if [ ! -d /var/www/html ]
  then
    mkdir -p /var/www/html
    chown root:root /var/www/html
    chmod 755 /var/www/html
  fi 

  if [ ! -d /var/www/cgi-bin ]
  then
    mkdir -p /var/www/cgi-bin
    chown root:root /var/www/cgi-bin
    chmod 755 /var/www/cgi-bin
  fi 

  if [ ! -d /var/www/pub ]
  then
    mkdir -p /var/www/pub
    chown root:root /var/www/pub
    chmod 755 /var/www/pub
  fi 

  if [ -f /root_index.html ]
  then
    mv /root_index.html /var/www/html/index.html
    chown apache:apache /var/www/html/index.html
    chmod 660 /var/www/html/index.html
  fi
}

init_varlib_tree() {

    mkdir -p /var/lib/pulp/celery
    mkdir -p /var/lib/pulp/static
    mkdir -p /var/lib/pulp/uploads
    mkdir -p /var/lib/pulp/published/puppet/http
    mkdir -p /var/lib/pulp/published/puppet/https
    mkdir -p /var/lib/pulp/published/yum/http
    mkdir -p /var/lib/pulp/published/yum/https

    chown -R apache:apache /var/lib/pulp
    chmod -R 755 /var/lib/pulp

    if [ ! -f /var/lib/pulp/static/rsa_pub.key ]
    then
      ln -s /etc/pki/pulp/rsa_pub.key /var/lib/pulp/static/rsa_pub.key
    fi
}

place_ssl_key_and_cert() {
  curl --silent --retry 3 $SSL_TARBALL_URL > /tmp/ssl_keys.tar
  if [ $? != 0 ]; then
    echo "ERROR - Unable to retrieve SSL keys from $SSL_TARBALL_URL"
    echo "Unable to continue: exiting"
    exit 2
  fi
  tar -C /tmp -xf /tmp/ssl_keys.tar
  cp /tmp/localhost.crt ${CERT_FILE}
  chown root:root ${CERT_FILE}
  chmod 600 ${CERT_FILE}

  cp /tmp/localhost.key ${KEY_FILE}
  chown root:root ${KEY_FILE}
  chmod 600 ${KEY_FILE}

  rm /tmp/ssl_keys.tar
  rm /tmp/localhost.{crt,key}
}

configure_apache_server_name() {
  sed -i -e "s/^#ServerName www.example.com:80.*/ServerName $PULP_SERVER_NAME:80/" $HTTPD_CONF
  sed -i -e "s/^#ServerName www.example.com:443.*/ServerName $PULP_SERVER_NAME:443/" $SSL_CONF
}

configure_host_server_name() {
    echo $PULP_SERVER_NAME > /etc/hostname
    hostname $PULP_SERVER_NAME
}

# ==============================================================================
# MAIN
# ==============================================================================
#
# First, initialize the pulp server configuration
#
if [ ! -x /configure_pulp_server.sh ]
then
  echo >&2 "Missing required initialization script for pulp server: /configure_pulp_server.sh"
  exit 2
fi
. /configure_pulp_server.sh


# Create the WWW content trees if needed
init_www_tree
init_varlib_tree

# Set the ServerName for the web service
configure_host_server_name
configure_apache_server_name

#
# Place the SSL keys to enable encryption
#
if [ -n "$SSL_TARBALL_URL" ]
then
  place_ssl_key_and_cert
fi

# Start the HTTP master daemon
exec /usr/sbin/httpd -DFOREGROUND -E -
