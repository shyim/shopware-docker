for module in ./modules/*; do
    moduleBasename=$(basename $module)

    if [[ "$(ls -A ${module})" ]]; then
        echo "${green}Available commands in module: ${moduleBasename}${reset}"

        for command in ${module}/*.sh; do
            name=$(basename $command)
            name=${name%.*}
            usage=""

            if [[ -f "${module}/${name}.help" ]]; then
                usage=$(trim_whitespace "$(cat "${module}/${name}.help")")
            fi

            printf '%-32s' "${lightGreen}    ${name}"
            echo " ${usage}${reset}"
        done
        echo ""
    fi
done
