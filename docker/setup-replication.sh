#!/bin/bash

if [ "x$REPLICATE_FROM" == "x" ]; then

PGPASSWORD=$POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" --no-password --no-psqlrc <<EOSQL

CREATE ROLE $POSTGRES_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$POSTGRES_REP_PASSWORD';

EOSQL

cat >> "${PGDATA}/postgresql.conf" <<EOF
listen_addresses = '*'
wal_level = replica
wal_log_hints = on
max_wal_senders = ${PG_MAX_WAL_SENDERS}
max_wal_size = ${PG_MAX_WAL_SIZE}
archive_mode = on
archive_command = 'test ! -f /primary/pgarchives/%f && cp %p /primary/pgarchives/%f'
EOF

else

cat >> "${PGDATA}/postgresql.conf" <<EOF
listen_addresses = '*'
hot_standby = on
max_wal_senders = ${PG_MAX_WAL_SENDERS}
max_wal_size = ${PG_MAX_WAL_SIZE}
primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_REP_USER} password=${POSTGRES_REP_PASSWORD}'
promote_trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

touch "${PGDATA}/standby.signal"

fi
