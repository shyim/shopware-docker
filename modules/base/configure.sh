#!/usr/bin/env bash

if [[ -z "$EDITOR" ]]; then
    EDITOR="vi"
fi

$EDITOR "${HOME}/.config/swdc/env"
