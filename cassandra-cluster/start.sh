#!/bin/bash

/usr/sbin/sshd

exec /usr/local/bin/docker-entrypoint.sh cassandra -f
