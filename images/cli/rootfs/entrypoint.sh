#!/usr/bin/env sh

bash /usr/local/bin/setup_nvm

if [ -z "$1" ]; then
    exec bash
else
    exec "$@"
fi
