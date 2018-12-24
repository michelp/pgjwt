#!/bin/bash

DB_HOST="pgjwt-test-db"
DB_NAME="postgres"

POSTGRES_SU="postgres"

EXEC="docker exec $DB_HOST"

echo destroying any previous test container
docker rm --force "$DB_HOST"

echo building test image
docker build test --force-rm -t pgjwt/test

docker run -d --name "$DB_HOST" pgjwt/test 

echo waiting for database to accept connections
until
    $EXEC \
	    psql -o /dev/null -t -q -U "$POSTGRES_SU" \
        -c 'select pg_sleep(1)' \
	    2>/dev/null;
do sleep 1;
done

echo running tests
$EXEC pg_prove -U "$POSTGRES_SU" /pgjwt/test.sql
