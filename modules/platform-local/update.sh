#!/usr/bin/env bash
LOCAL_PROJECT_ROOT="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}"
cd "$LOCAL_PROJECT_ROOT" || exit

if [[ -e platform/.git ]]; then
    git -C platform pull
fi

if [[ -e .git ]]; then
    git pull
fi

compose exec cli bash /opt/swdc/swdc-inside update "${SHOPWARE_PROJECT}"