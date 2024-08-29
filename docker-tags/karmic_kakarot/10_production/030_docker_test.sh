#!/bin/bash

# Load env variables
. ../env.sh

# -----------------------------------------------------------------
#
# Starts a PG container
#
# -----------------------------------------------------------------
docker run -ti --rm \
    --name docker_postgis_test \
    --hostname docker_postgis_test \
    -e LOCALE=es_ES \
    -e POSTGRES_PASSWORD=postgres_aaa \
    -p 6432:5432 \
    malkab/postgis:${DOCKER_IMAGE_TAG}
