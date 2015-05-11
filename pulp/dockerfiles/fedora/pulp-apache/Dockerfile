FROM markllama/pulp-base
MAINTAINER Mark Lamourine <markllama@gmail.com>

#
# docker run -d --name pulp-apache \
#   -v /dev/log:/dev/log --volumes-from pulp-content
#   -p 443:443 \
#   -e PULP_SERVER_NAME=pulp.example.com \
#   -e SSL_TARBALL_URL=<url> markllama/pulp-apache
#
#   SSL_TARBALL_URL must retrieve a TAR archive containing two files
#      localhost.crt
#      localhost.key
#
#   These must be a key and signed certificate for the hostname indicated
#   in PULP_SERVER_NAME

VOLUME [ "/var/www", "/var/lib/pulp" ]

WORKDIR /usr/share/httpd

EXPOSE 80 443

ADD run.sh /run.sh

CMD [ "/run.sh" ]
