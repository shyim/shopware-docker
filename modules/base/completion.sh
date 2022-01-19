#!/usr/bin/env bash

FOUND_CMDS=$(find $DIR/modules/* -maxdepth 1 -mindepth 1 -iname "*.sh")

if [[ -e "$HOME/.config/swdc/modules/" ]]; then
    # shellcheck disable=SC2086
    FOUND_CMDS=$(find $DIR/modules/* $HOME/.config/swdc/modules/* -maxdepth 1 -mindepth 1 -iname "*.sh")
fi

AVAILABLE_CMDS=""

for file in $FOUND_CMDS; do
    file=$(basename "$file")
    file=${file%.*}

    AVAILABLE_CMDS="$AVAILABLE_CMDS $file"
done

read -ra completions <<<"$2"

if [[ "${#completions[@]}" == 1 ]]; then
    for file in $AVAILABLE_CMDS; do
        echo "$file"
    done
elif [[ "${#completions[@]}" == 2 ]]; then
    foundCmd=0
    for file in $AVAILABLE_CMDS; do
        if [[ "$file" == "${completions[1]}" ]]; then
            foundCmd=1
        fi
    done

    if [[ "$foundCmd" == 0 ]]; then
        for file in $AVAILABLE_CMDS; do
            echo "$file"
        done

        exit 0
    fi

    # shellcheck disable=SC2044
    for file in $(find "$CODE_DIRECTORY/" -maxdepth 1 -mindepth 1); do
        file=$(basename "$file")

        echo "$file"
    done
else
    foundCmd=0
    # shellcheck disable=SC2044
    for file in $(find "$CODE_DIRECTORY/" -maxdepth 1 -mindepth 1); do
        file=$(basename "$file")
        if [[ "$file" == "${completions[2]}" ]]; then
            foundCmd=1
        fi
    done

    if [[ "$foundCmd" == 0 ]]; then
        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/" -maxdepth 1 -mindepth 1); do
            file=$(basename "$file")

            echo "$file"
        done

        exit 0
    fi



    build_arg=${completions[1]}

    if [[ "$build_arg" == "snap" || "$build_arg" == "rsnap" ]]; then
        # shellcheck disable=SC2044
        for file in $(find "$CODE_DIRECTORY/snapshots/" -maxdepth 1 -mindepth 1 -iname "$3*.sql"); do
            file=$(basename "$file" | cut -d '-' -f 2)
            file=${file%.*}

            echo "$file"
        done
    elif [[ "$build_arg" == "build" ]]; then
        echo "--mysql-host"
        echo "--without-demo-data"
        echo "--without-building"
    elif [[ "$build_arg" == "check" ]]; then
        echo "ecs"
        echo "static-analyse"
        echo "phpstan"
        echo "psalm"
    elif [[ "$build_arg" == "config-add" || "$build_arg" == "config-remove" ]]; then
        echo "disable-csrf"
        echo "array-cache"
        echo "redis-session"
        echo "redis-message-queue-stats"
        echo "disable-profiler"
    fi
fi