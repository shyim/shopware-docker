#!/usr/bin/env bash

if [[ ! -e /nvm/versions/ ]]; then
  git clone --depth=1 https://github.com/shyim/nvm-alpine.git /nvm

  # shellcheck source=/dev/null
  source /nvm/nvm.sh
  nvm install v12.20.1
  nvm use v12.20.1
fi