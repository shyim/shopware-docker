#!/usr/bin/env bash

phpVersions=(php56 php70 php71 php72 php73)

for t in ${phpVersions[@]}; do
  dockerPHP=$(echo "${t:3:1}.${t:4:1}")

  echo "{\"phpVersion\": \"$dockerPHP\"}" | mustache - cli/Dockerfile.mustache > cli/${t}/Dockerfile
done
