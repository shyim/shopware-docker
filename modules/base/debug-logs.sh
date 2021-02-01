#!/usr/bin/env bash

echo "=== docker-compose.yml" >debug.txt
echo "" >>debug.txt

cat "$DOCKER_COMPOSE_FILE" >>debug.txt

echo "" >>debug.txt
echo "" >>debug.txt

cho "" >>debug.txt
echo "" >>debug.txt

echo "=== .env" >>debug.txt
echo "" >>debug.txt

cat "${HOME}/.config/swdc/env" >>debug.txt

echo "" >>debug.txt
echo "" >>debug.txt

echo "=== mysql logs" >>debug.txt
echo "" >>debug.txt

docker-compose logs mysql >>debug.txt

echo "Generated a debug.txt file. Please post it on Github"
