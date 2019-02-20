#!/usr/bin/env bash

FILE="$0"

if [ -L "$0" ]; then
  FILE=$(readlink "$0")
fi

DIR=$(dirname ${FILE})

source "${DIR}/functions.sh"

rm -r cli/php*
rm -r nginx/php*

for t in ${phpVersions[@]}; do
  dockerPHP=$(echo "${t:3:1}.${t:4:1}")

  if [ ! -d "cli/${t}" ]; then
    mkdir cli/${t}
  fi

  if [ ! -d "nginx/${t}" ]; then
    mkdir nginx/${t}
  fi

  echo "{\"phpVersion\": \"$dockerPHP\"}" | mustache - cli/Dockerfile.mustache > cli/${t}/Dockerfile

  echo "{\"phpVersion\": \"$dockerPHP\"}" | mustache - nginx/Dockerfile.mustache > nginx/${t}/Dockerfile
done

for t in ${xdebugPhpVersions[@]}; do
  if [ ! -d "nginx/${t}-xdebug" ]; then
    mkdir nginx/${t}-xdebug
  fi

  echo "{\"phpVersion\": \"$t\"}" | mustache - nginx/Dockerfile-xdebug.mustache > nginx/${t}-xdebug/Dockerfile
done

for t in ${mysqlVersions[@]}; do
  if [ ! -d "mysql/${t}" ]; then
    mkdir mysql/${t}
  fi

  if [ ${t} == "8" ]; then
    mysql="8.0"
  else
    mysql=$(echo "${t:0:1}.${t:1:1}")
  fi

  echo "{\"mysqlVersion\": \"$mysql\"}" | mustache - mysql/Dockerfile.mustache > mysql/${t}/Dockerfile
done