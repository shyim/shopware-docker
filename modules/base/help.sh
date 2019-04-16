#!/usr/bin/env bash

REQUESTEDCOMMAND=$2

if [[ -z "$REQUESTEDCOMMAND" ]]; then
    echo "Usage:"
    echo "  help [<command_name>]"
    exit 0
fi

FOUNDCLI=false

for module in ${MODULES[@]}; do
    for command in ./modules/${module}/*.sh; do
        NAME=$(basename $command)
        NAME=${NAME%.*}

        if [[ $NAME == $REQUESTEDCOMMAND ]]; then
            cat ./modules/${module}/${NAME}.usage
            echo ""
            FOUNDCLI=true
        fi
    done
done

if [[ $FOUNDCLI == "false" ]]; then
    echo "Command $REQUESTEDCOMMAND does not exist"
fi