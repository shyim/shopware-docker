#!/usr/bin/env bash

SHOPWARE_PROJECT=$2
SHOPWARE_FOLDER=~/Code/${SHOPWARE_PROJECT}
URL=http://${SHOPWARE_PROJECT}.dev.localhost

if [[ -f "$SHOPWARE_FOLDER/src/RequestTransformer.php" ]]; then
    URL=http://${SHOPWARE_PROJECT}.platform.localhost
fi

checkParameter

if which xdg-open > /dev/null
then
  xdg-open ${URL}
elif which gnome-open > /dev/null
then
  gnome-open ${URL}
fi