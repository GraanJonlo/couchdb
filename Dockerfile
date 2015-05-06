FROM phusion/baseimage:0.9.16

MAINTAINER Andy Grant <andy.a.grant@gmail.com>

RUN echo "deb http://binaries.erlang-solutions.com/debian `lsb_release -cs` contrib" | tee /etc/apt/sources.list.d/erlang-solutions.list

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    lsb-release \
    wget

ENV ERLANG_VERSION 17.5

RUN wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add - && \
    apt-get update && apt-get install -y \
    build-essential \
    curl \
    erlang-base-hipe=1:$ERLANG_VERSION \
    erlang-dev=1:$ERLANG_VERSION \
    erlang-nox=1:$ERLANG_VERSION \
    libcurl4-openssl-dev \
    libicu-dev \
    libmozjs185-1.0 \
    libmozjs185-dev \
    libnspr4 \
    libnspr4-0d \
    libnspr4-dev

# Add CouchDB user
RUN groupadd -r couchdb && useradd -d /var/lib/couchdb -g couchdb couchdb && \
    mkdir -p /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb /var/lib/couchdb /usr/src/couchdb && \
    chown -R couchdb:couchdb /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb && \
    chmod -R g+rw /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb

ENV COUCHDB_VERSION 1.6.1

RUN curl -sSL http://mirrors.ukfast.co.uk/sites/ftp.apache.org/couchdb/source/$COUCHDB_VERSION/apache-couchdb-$COUCHDB_VERSION.tar.gz -o couchdb.tar.gz && \
    tar -xzf couchdb.tar.gz -C /usr/src/couchdb --strip-components=1 && \
    cd /usr/src/couchdb && \
    ./configure --with-js-lib=/usr/lib --with-js-include=/usr/include/mozjs && \
    make && make install

RUN rm -rf /var/lib/apt/lists/*

RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini

VOLUME ["/usr/local/var/log/couchdb", "/usr/local/var/lib/couchdb"]

RUN mkdir /etc/service/couchdb
ADD couchdb.sh /etc/service/couchdb/run

EXPOSE 5984

CMD ["/sbin/my_init", "--quiet"]

