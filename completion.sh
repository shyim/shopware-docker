#!/usr/bin/env bash

# shellcheck disable=SC2128
if [[ -z "${BASH_SOURCE}" ]]; then
    # shellcheck disable=SC2296
    BASH_SOURCE=${(%):-%N}
fi

# shellcheck disable=SC2128
DIR="$(dirname "${BASH_SOURCE}")"
CONFIG_DIR=${XDG_CONFIG_HOME:-${HOME}/.config}

# shellcheck source=.env.dist
source "${CONFIG_DIR}/swdc/env"

# shellcheck disable=SC2086
AVAILABLE_CMDS=$(find $DIR/modules/* -maxdepth 1 -mindepth 1 -iname "*.sh")

if [[ -e "$HOME/.config/swdc/modules/" ]]; then
    # shellcheck disable=SC2086
    AVAILABLE_CMDS=$(find $DIR/modules/* $HOME/.config/swdc/modules/* -maxdepth 1 -mindepth 1 -iname "*.sh")
fi

function __list_swdc_commands {

    prev_arg="${COMP_WORDS[COMP_CWORD-2]}";
    build_arg=$prev_arg

    if [[ -n "${COMP_WORDS[1]}" ]]; then
        build_arg=${COMP_WORDS[1]}
    fi

    if [[ "$3" == "swdc" ]]; then
        local cmds
        for file in $AVAILABLE_CMDS; do
            file=$(basename "$file")
            file=${file%.*}

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$AVAILABLE_CMDS" == *"$3"* ]]; then
        local cmds

        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/" -maxdepth 1 -mindepth 1); do
            file=$(basename "$file")

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$build_arg" == "snap" || "$build_arg" == "rsnap" ]]; then
        local cmds

        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/snapshots/" -maxdepth 1 -mindepth 1 -iname "$3*.sql"); do
            file=$(basename "$file" | cut -d '-' -f 2)
            file=${file%.*}

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$build_arg" == "build" ]]; then

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W '--mysql-host --without-demo-data --without-building' -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$build_arg" == "check" ]]; then

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W 'ecs static-analyse phpstan psalm' -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$build_arg" == "config-add" || "$build_arg" == "config-remove" ]]; then

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W '-e disable-csrf array-cache redis-session redis-message-queue-stats disable-profiler' -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ "$build_arg" == "e2e" ]]; then

        if [[ "${#COMP_WORDS[@]}" == "5" ]]; then
          project="${COMP_WORDS[COMP_CWORD-2]}"

          local cmds

          # shellcheck disable=SC2044
          for file in $(find "$CODE_DIRECTORY/$project/custom/plugins" -maxdepth 1 -mindepth 1); do
            file=$(basename "$file" | cut -d '-' -f 2)
            file=${file%.*}

            cmds="$cmds $file"
          done

          # shellcheck disable=SC2207
          COMPREPLY=($(compgen -W "$cmds" -- "${COMP_WORDS[COMP_CWORD]}"))
        else
          # shellcheck disable=SC2207
          COMPREPLY=($(compgen -W 'Administration Storefront' -- "${COMP_WORDS[COMP_CWORD]}"))
        fi
    fi

    return 0;
}

complete -F __list_swdc_commands swdc
