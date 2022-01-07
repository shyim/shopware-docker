#!/usr/bin/env bash

checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

FILE="config/packages/swdc.yml"

touch "$FILE"

if [[ "$#" != 0 ]]; then
  while (($#)); do
    case $1 in
    -e)
      shift

      if [[ ! -d "config/packages/$1" ]]; then
        mkdir "config/packages/$1"
      fi

      FILE="config/packages/$1/swdc.yml"
      touch "$FILE"
      ;;
    disable-csrf)
      yq e -i '.storefront.csrf.enabled=false' "$FILE"
      ;;
    array-cache)
      yq e -i '.framework.cache.app="cache.adapter.array"' "$FILE"
      ;;
    redis-session)
      yq e -i '.framework.session.handler_id="redis://redis"' "$FILE"
      ;;
    redis-message-queue-stats)
      yq e -i '.shopware.increment.message_queue.type="redis"' "$FILE"
      yq e -i '.shopware.increment.message_queue.config.url="redis://redis"' "$FILE"
      ;;
    disable-profiler)
      yq e -i '.web_profiler.toolbar=false' "$FILE"
      yq e -i '.framework.profiler.collect=false' "$FILE"
      ;;
    esac
    shift
  done
fi