#!/usr/bin/env bash

echo "=== docker-compose.yml" > debug.txt
echo "" >> debug.txt

cat docker-compose.yml >> debug.txt

echo "" >> debug.txt
echo "" >> debug.txt

echo "=== docker-compose.override.yaml" >> debug.txt
echo "" >> debug.txt

cat docker-compose.override.yaml >> debug.txt

echo "" >> debug.txt
echo "" >> debug.txt

echo "=== .env" >> debug.txt
echo "" >> debug.txt

cat "${HOME}/.config/swdc/env" >> debug.txt

echo "" >> debug.txt
echo "" >> debug.txt

echo "=== mysql logs" >> debug.txt
echo "" >> debug.txt

docker-compose logs mysql >> debug.txt

echo "Generated a debug.txt file. Please post it on Github"