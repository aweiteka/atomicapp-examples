FROM markllama/pulp-base
MAINTAINER Mark Lamourine <markllama@gmail.com>
#
# Pulp Worker service - coordinate activities
#
# Environment Variables:
#  DB_SERVICE_HOST: name or IP address of the MongoDB server
#  DB_SERVICE_PORT: TCP port for MongoDB (default: 27017)
#  MSG_SERVICE_HOST: name or IP address of the qpid server
#  MSG_SERVICE_PORT: TCP port for qpidd (default: 5672)
#  PULP_SERVER_NAME: The public server name of the HTTP services
#
# must be started with -v /dev/log:/dev/log
#
# For worker #1:
#
# docker run -d --name pulp-worker-1 \
#   -v /dev/log:/dev/log --volumes-from pulp-content \
#   -e PULP_SERVER_NAME=pulp.example.com \
#   -e DB_SERVICE_HOST=<ip> -e MSG_SERVICE_HOST = <ip> \
#   markllama/pulp-worker 1


VOLUME [ "/var/www", "/var/lib/pulp" ]

ADD run.sh /run.sh

# Usage: /run.sh <worker number>
ENTRYPOINT ["/run.sh"]
