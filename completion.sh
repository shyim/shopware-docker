#!/usr/bin/env bash

# shellcheck disable=SC2128
DIR="$(dirname "${BASH_SOURCE}")"
CONFIG_DIR=${XDG_CONFIG_HOME:-${HOME}/.config}

# shellcheck source=.env.dist
source "${CONFIG_DIR}/swdc/env"

# shellcheck disable=SC2086
AVAILABLE_CMDS=$(find $DIR/modules/* -maxdepth 1 -mindepth 1 -iname "*.sh")

function __list_swdc_commands {
    prev_arg="${COMP_WORDS[COMP_CWORD-2]}";

    if [[ "$3" == "swdc" ]]; then
        local cmds
        for file in $AVAILABLE_CMDS; do
            file=$(basename "$file")
            file=${file%.*}

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[1]}"))
    elif [[ "$AVAILABLE_CMDS" == *"$3"* ]]; then
        local cmds

        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/" -maxdepth 1 -mindepth 1); do
            file=$(basename "$file")

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[2]}"))
    elif [[ "$prev_arg" == "snap" || "$prev_arg" == "rsnap" ]]; then
        local cmds

        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/snapshots/" -maxdepth 1 -mindepth 1 -iname "$3*.sql"); do
            file=$(basename "$file" | cut -d '-' -f 2)
            file=${file%.*}

            cmds="$cmds $file"
        done

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W "$cmds" "${COMP_WORDS[3]}"))
    elif [[ "$prev_arg" == "build" ]]; then

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W '--mysql-host --without-demo-data --without-building' -- "${COMP_WORDS[3]}"))
    elif [[ "$prev_arg" == "check" ]]; then

        # shellcheck disable=SC2207
        COMPREPLY=($(compgen -W 'ecs static-analyse' -- "${COMP_WORDS[3]}"))
    fi

    return 0;
}

complete -F __list_swdc_commands swdc