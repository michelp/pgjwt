#!/bin/bash

set -e

DB_HOST="pgjwt-test-db"
DB_NAME="postgres"
SU="postgres"
EXEC="docker exec $DB_HOST"

echo building test image
docker build . --force-rm -t pgjwt/test

echo running test container
docker run -d --name "$DB_HOST" pgjwt/test 

echo waiting for database to accept connections
until
    $EXEC \
	    psql -o /dev/null -t -q -U "$SU" \
        -c 'select pg_sleep(1)' \
	    2>/dev/null;
do sleep 1;
done

echo running tests
$EXEC pg_prove -U "$SU" /pgjwt/test.sql

echo destroying test container and image
docker rm --force "$DB_HOST"
docker rmi pgjwt/test
