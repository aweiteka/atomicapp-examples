FROM fedora:21
MAINTAINER Mark Lamourine <markllama@gmail.com>

#COMMENT { "description": "mongodb service container", \ 
#          "usage": "docker run -d -p 27017:27017 --name mongodb fedora/mongodb --volume=/mydbdatadir:/var/lib/mongodb" }

RUN  yum install -y mongodb-server && \
     yum clean all

RUN  mkdir -p /var/lib/mongodb && \
     touch /var/lib/mongodb/.keep && \
     chown -R mongodb:mongodb /var/lib/mongodb

ADD mongodb.conf /etc/mongodb.conf

VOLUME [ "/var/lib/mongodb" ]

EXPOSE 27017

RUN yum install -y hostname iproute && yum clean all

USER mongodb

WORKDIR /var/lib/mongodb

ENTRYPOINT ["/usr/bin/mongod", "--config", "/etc/mongodb.conf"]
CMD ["--quiet"]

