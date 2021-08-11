#!/usr/bin/env bash

LOCAL_MODULES_DIR="$HOME/.config/swdc/modules"

if [[ -n $SWDC_IN_DOCKER ]]; then
  LOCAL_MODULES_DIR="/swdc-cfg/modules"
fi

for module in ./modules/*; do
  moduleBasename=$(basename "$module")

  if [[ "$(ls -A "${module}")" ]]; then
    echo "${green:-}Available commands in module: ${moduleBasename}${reset:-}"

    for command in "${module}"/*.sh; do
      name=$(basename "$command")
      name=${name%.*}
      usage=""

      if [[ -f "${module}/${name}.help" ]]; then
        usage=$(trim_whitespace "$(cat "${module}/${name}.help")")
      fi

      printf '%-32s' "${lightGreen:-}    ${name}"
      echo " ${usage}${reset:-}"
    done
    echo ""

    if [[ -e "${LOCAL_MODULES_DIR}/${moduleBasename}" ]]; then
      if [[ "$(ls -A "${LOCAL_MODULES_DIR}/${moduleBasename}")" ]]; then
        echo "${green:-}Available commands in module: ${moduleBasename} [LOCAL]${reset:-}"

        for command in "${LOCAL_MODULES_DIR}/${moduleBasename}"/*.sh; do
          name=$(basename "$command")
          name=${name%.*}
          usage=""

          if [[ -f "${module}/${name}.help" ]]; then
            usage=$(trim_whitespace "$(cat "${module}/${name}.help")")
          fi

          printf '%-32s' "${lightGreen:-}    ${name}"
          echo " ${usage}${reset:-}"
        done
      fi
    fi
    echo ""
  fi
done
