#!/usr/bin/env bash

for module in ./modules/*; do
  moduleBasename=$(basename "$module")

  if [[ "$moduleBasename" == *local || "$moduleBasename" == "defaults" || "$moduleBasename" == "classic-composer" || $moduleBasename == "classic-zip" || "$moduleBasename" == "platform-prod" ]]; then
    continue
  fi

  if [[ "$(ls -A "${module}")" ]]; then
    echo "### Module: ${moduleBasename}"
    echo ""
    echo "| Command                                  | Description                                                       |"
    echo "| ---------------------------------------- | ----------------------------------------------------------------- |"

    for command in "${module}/"*.sh; do
      name=$(basename "$command")
      name=${name%.*}
      usage=""

      if [[ -f "${module}/${name}.help" ]]; then
        usage=$(trim_whitespace "$(cat "${module}/${name}.help")")
      fi

      if [[ "$moduleBasename" == "base" ]]; then
        printf "| \`swdc %s\` | " "${name}"
      else
        printf "| \`swdc %s <project-name>\` | " "${name}"
      fi
      echo "${usage} | "
    done

    if [[ -e "${module}-local" ]]; then
      for command in "${module}-local/"*.sh; do
        name=$(basename "$command")
        name=${name%.*}
        usage=""

        if [[ -f "${module}-local/${name}.help" ]]; then
          usage=$(trim_whitespace "$(cat "${module}-local/${name}.help")")
        fi

        if [[ "$moduleBasename" == "base" ]]; then
          printf "| \`swdc %s\` | " "${name}"
        else
          printf "| \`swdc %s <project-name>\` | " "${name}"
        fi
        echo "${usage} | "
      done
      echo ""
    fi
  fi
done
