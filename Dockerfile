FROM postgres:14

ENV PG_MAX_WAL_SENDERS 5
ENV PG_MAX_WAL_SIZE 1GB

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker/setup-replication.sh /docker-entrypoint-initdb.d/setup-replication.sh

RUN chmod +x /docker-entrypoint-initdb.d/setup-replication.sh /usr/local/bin/docker-entrypoint.sh
RUN mkdir /primary/pgarchives -p && chown postgres:postgres /primary/pgarchives
