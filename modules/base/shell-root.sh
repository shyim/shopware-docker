#!/usr/bin/env bash

docker-compose exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -e SHELL=bash -u 0 cli bash