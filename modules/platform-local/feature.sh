#!/usr/bin/env bash

checkParameter
cd "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}" || exit

buildDir="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}/build"

if [[ ! -d "${buildDir}" ]]; then
    mkdir "${buildDir}"
fi

editor "${buildDir}/feature.env"