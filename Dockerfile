# Set base image to Debian
FROM graanjonlo/erlang:17.4

# File Author / Maintainer
MAINTAINER Andy Grant <andy.a.grant@gmail.com>

# Common set up
RUN \
    apt-get update && \
    apt-get install -y curl apt-utils wget && \
    apt-get upgrade -y

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# CouchDB dependencies
RUN \
    apt-get install -y libmozjs185-1.0 libmozjs185-dev build-essential libnspr4 libnspr4-0d libnspr4-dev libcurl4-openssl-dev curl libicu-dev

# Add CouchDB user
RUN \
    groupadd -r couchdb && useradd -d /var/lib/couchdb -g couchdb couchdb && \
    mkdir -p /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb /var/lib/couchdb /usr/src/couchdb && \
    chown -R couchdb:couchdb /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb && \
    chmod -R g+rw /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb

ENV COUCHDB_VERSION 1.6.1

# Install CouchDB
RUN \
    curl -sSL http://mirrors.ukfast.co.uk/sites/ftp.apache.org/couchdb/source/$COUCHDB_VERSION/apache-couchdb-$COUCHDB_VERSION.tar.gz -o couchdb.tar.gz && \
    tar -xzf couchdb.tar.gz -C /usr/src/couchdb --strip-components=1 && \
    cd /usr/src/couchdb && \
    ./configure --with-js-lib=/usr/lib --with-js-include=/usr/include/mozjs && \
    make && make install

# Remove package lists as we no longer need them
RUN rm -rf /var/lib/apt/lists/*

# Expose to the outside
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

# Define mountable directories
VOLUME ["/usr/local/var/log/couchdb", "/usr/local/var/lib/couchdb"]

# Set entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 5984

# Define default command.
CMD ["couchdb"]

