#!/usr/bin/bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
COMMIT_SHA=$(cd "$SCRIPT_DIR" && git rev-parse HEAD)
docker build --tag="replication_postgres:${COMMIT_SHA}" "$SCRIPT_DIR"


docker network create --driver=bridge --subnet=172.117.0.0/16 replication || true


docker volume create primary_pgdata
docker volume create pgarchives


docker container rm postgres_primary || true
docker run --detach --name=postgres_primary --ipc=host --net=replication --ip=172.117.0.2 --log-opt=tag="{{.Name}}" \
    --volume=primary_pgdata:/primary/pgdata \
    --volume=pgarchives:/primary/pgarchives \
    --env=POSTGRES_USER=marcin \
    --env=POSTGRES_PASSWORD=marcin_password \
    --env=POSTGRES_DB=marcin_database \
    --env=POSTGRES_REP_USER=rep \
    --env=POSTGRES_REP_PASSWORD=rep_password \
    --env=POSTGRES_INITDB_WALDIR=/primary/pginitdbwaldir \
    --env=PGDATA=/primary/pgdata \
    "replication_postgres:${COMMIT_SHA}"


docker logs --details=true --timestamps postgres_primary -f &
