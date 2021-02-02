#!/usr/bin/env bash

{
  echo "=== docker-compose.yml"
  echo ""

  cat "$DOCKER_COMPOSE_FILE"

  echo ""
  echo ""

  cho ""
  echo ""

  echo "=== .env"
  echo ""

  cat "${HOME}/.config/swdc/env"

  echo ""
  echo ""

  echo "=== mysql logs"
  echo ""

  docker-compose logs mysql
} > debug.txt

echo "Generated a debug.txt file. Please post it on Github"
