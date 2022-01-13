#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1

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
      yq e -i 'del(.storefront.csrf)' "$FILE"
      ;;
    array-cache)
      yq e -i 'del(.framework.cache)' "$FILE"
      ;;
    redis-session)
      yq e -i 'del(.framework.session)' "$FILE"
      ;;
    redis-message-queue-stats)
      yq e -i 'del(.shopware.increment.message_queue)' "$FILE"
      ;;
    disable-profiler)
      yq e -i 'del(.web_profiler.toolbar)' "$FILE"
      yq e -i 'del(.framework.profiler)' "$FILE"
      ;;
    esac
    shift
  done
fi