#!/usr/bin/env bash

if [[ -z "$2" ]]; then
  compose exec -e COLUMNS -e LINES -e SHELL=bash cli bash
else
  shift
  compose exec -e COLUMNS -e LINES -e SHELL=bash cli "$@"
fi
