#!/bin/bash

chown couchdb:couchdb /usr/local/etc/couchdb
chmod 0755 /usr/local/etc/couchdb
chown couchdb:couchdb /usr/local/var/log/couchdb
chmod 0755 /usr/local/var/log/couchdb
chown couchdb:couchdb /usr/local/var/lib/couchdb
chmod 0755 /usr/local/var/lib/couchdb
chown couchdb:couchdb /usr/local/var/run/couchdb
chmod 0755 /usr/local/var/run/couchdb

exec /sbin/setuser couchdb /usr/local/bin/couchdb

