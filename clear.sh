#!/usr/bin/bash
set -xeuo pipefail

docker-compose rm --force
docker volume ls | (grep replication || true) | awk '{print $2}' | xargs -I {}  docker volume rm -f {}

# or simply
# docker-compose down --volumes
