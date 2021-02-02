#!/usr/bin/env bash

for module in ./modules/*; do
  moduleBasename=$(basename "$module")

  if [[ "$(ls -A "${module}")" ]]; then
    echo "### Module: ${moduleBasename}"
    echo ""

    for command in ${module}/*.sh; do
      name=$(basename "$command")
      name=${name%.*}
      usage=""

      if [[ -f "${module}/${name}.help" ]]; then
        usage=$(trim_whitespace "$(cat "${module}/${name}.help")")
      fi

      printf '%-35s' "* \`swdc ${name}\`"
      printf "$usage\n"
    done
    echo ""
  fi
done
