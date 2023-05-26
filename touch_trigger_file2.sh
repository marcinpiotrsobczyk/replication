#!/bin/bash

docker exec postgres_replica2 bash -c 'touch /tmp/touch_me_to_promote_to_me_master'
