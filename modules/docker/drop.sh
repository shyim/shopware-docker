#!/usr/bin/env bash

checkParameter
mysql -h mysql -u root -proot -e "DROP DATABASE $SHOPWARE_PROJECT"