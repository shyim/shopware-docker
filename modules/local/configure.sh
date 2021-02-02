#!/usr/bin/env bash

if [[ -z $EDITOR ]]; then
  # shellcheck disable=SC2016
  echo 'Please set $EDITOR to use swdc configure'
  exit 0
fi

$EDITOR "${HOME}/.config/swdc/env"
