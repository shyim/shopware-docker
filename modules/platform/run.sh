#!/usr/bin/env bash
shift 1
cd "${CODE_DIRECTORY}/$1" || exit 1

shift 1
exec "$@"
