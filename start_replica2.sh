#!/usr/bin/bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
COMMIT_SHA=$(cd "$SCRIPT_DIR" && git rev-parse HEAD)
docker build --tag="replication_postgres:${COMMIT_SHA}" "$SCRIPT_DIR"


docker network create --driver=bridge --subnet=172.117.0.0/16 replication || true


docker volume create replica_pgdata2


docker container rm postgres_replica2 || true
docker run --name=postgres_replica2 --ipc=host --net=replication --ip=172.117.0.4 --log-opt=tag="{{.Name}}" \
    --volume=replica_pgdata2:/replica/pgdata \
    --env=POSTGRES_USER=marcin \
    --env=POSTGRES_PASSWORD=marcin_password \
    --env=POSTGRES_DB=marcin_database \
    --env=POSTGRES_REP_USER=rep \
    --env=POSTGRES_REP_PASSWORD=rep_password \
    --env=PGDATA=/replica/pgdata \
    --env=REPLICATE_FROM=postgres_primary \
    "replication_postgres:${COMMIT_SHA}"
