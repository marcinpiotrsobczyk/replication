#!/usr/bin/bash
set -xeuo pipefail

BLUE='\033[0;34m' # Blue
NC='\033[0m' # No Color


echo -e "${BLUE}cleaning containers${NC}"
docker ps -a | (grep postgres_primary || true) | awk '{print $1}' | xargs -I {} docker container stop {}
docker ps -a | (grep postgres_primary || true) | awk '{print $1}' | xargs -I {} docker container rm {}
docker ps -a | (grep postgres_replica || true) | awk '{print $1}' | xargs -I {} docker container stop {}
docker ps -a | (grep postgres_replica || true) | awk '{print $1}' | xargs -I {} docker container rm {}

echo -e "${BLUE}cleaning volumes${NC}"
docker volume rm primary_pgdata || echo 'volume primary_pgdata already cleaned up'
docker volume rm pgarchives || echo 'volume pgarchives already cleaned up'
docker volume rm replica_pgdata || echo 'volume replica_pgdata already cleaned up'
docker volume ls | (grep replica_pgdata || true) | awk '{print $2}' | xargs -I {} docker volume rm {}


echo -e "${BLUE}cleaning networks${NC}"
docker network rm replication || echo 'network replcation already cleaned up'
