#!/usr/bin/env bash

REQUESTEDCOMMAND=$2

if [[ -z "$REQUESTEDCOMMAND" ]]; then
  echo "Usage:"
  echo "  help [<command_name>]"
  exit 0
fi

FOUNDCLI=false

for module in ./modules/*; do
  for command in ${module}/*.sh; do
    NAME=$(basename "$command")
    NAME=${NAME%.*}

    if [[ $NAME == "${REQUESTEDCOMMAND}" ]]; then
      FOUNDCLI=true
      usageFile=${module}/${NAME}.usage

      if [[ -e $usageFile ]]; then
        cat "${module}"/"${NAME}".usage
        echo ""
      else
        echo "Command ${NAME} don't have currently a usage. Maybe want to contribute one?"
      fi
    fi
  done
done

if [[ $FOUNDCLI == "false" ]]; then
  echo "Command $REQUESTEDCOMMAND does not exist"
fi
