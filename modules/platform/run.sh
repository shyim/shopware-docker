#!/usr/bin/env bash
shift 1
cd "/var/www/html/$1" || exit 1

shift 1
exec "$@"
