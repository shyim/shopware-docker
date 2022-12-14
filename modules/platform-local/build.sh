#!/usr/bin/env bash

ORIGINAL_ARGS=("$@")
dockerBuild=0

shift 2

while (($#)); do
  case $1 in
  --docker-build)
    dockerBuild=1
    ;;
  esac
  shift
done

if [[ $dockerBuild == 1 ]]; then
  compose stop app_"$SHOPWARE_PROJECT"
  compose up -d --build app_"$SHOPWARE_PROJECT" --remove-orphans
fi

compose exec cli bash /opt/swdc/swdc-inside "${ORIGINAL_ARGS[@]}"