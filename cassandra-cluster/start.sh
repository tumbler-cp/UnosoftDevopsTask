#!/bin/sh

service ssh start

exec docker-entrypoint.sh "$@"