# How to use this image

## start a couchdb instance

`docker run -d --name couchdb -p 5984:5984 -v /some/dir:/usr/local/var/lib/couchdb -v /another/dir:/usr/local/var/log/couchdb graanjonlo/couchdb`

This image includes `EXPOSE 5984` (the mongo port), so standard container linking will make it automatically available to the linked containers. It also includes `VOLUME ["/usr/local/var/lib/couchdb", "/usr/local/var/log/couchdb"]` so you can mount data volumes.
