#!/usr/bin/env bash

if [[ "${ELASTICSEARCH_IMAGE}" == *"amazon" ]]; then
    compose exec cli curl --user admin:admin -s -X DELETE 'http://elastic:9200/*,-.opendistro_security'
else
    compose exec cli curl --user admin:admin -s -X DELETE 'http://elastic:9200/_all'
fi
