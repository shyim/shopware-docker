#!/usr/bin/env bash
source ".env"
base_name="$(basename "${DIR}")"
container_name="${base_name}_${2}_1"
example_containers="$(docker ps --all --format "table {{.Names}}" | grep "${base_name}")"
running_container="$(docker ps --all --format "table {{.Names}}" | grep "${container_name}")"
if [[ "${running_container}" == "" ]]; then
  echo "${red}no such container${reset}"
  echo "${blue}try one of these:"
  echo "${example_containers}${reset}"
  exit "1"
fi
if [[ "${3}" == '-f' ]]; then
  docker container logs "${container_name}" -f
else
  docker container logs "${container_name}"
fi
