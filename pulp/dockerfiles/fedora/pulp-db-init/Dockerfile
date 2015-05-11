FROM markllama/pulp-base
MAINTAINER Mark Lamourine <markllama@gmail.com>

#
# Pulp Init DB  service - coordinate activities
#
# Environment Variables:
#  PULP_DB_SERVICE_HOST: name or IP address of the MongoDB server
#  PULP_DB_SERVICE_PORT: TCP port for MongoDB (default: 27017)
#
# must be started with -v /dev/log:/dev/log
#

ADD run.sh /run.sh

CMD [ "/run.sh" ]
