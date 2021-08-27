#!/usr/bin/env bash

docker run \
    --rm \
    -v "shopware-docker_tool_cache:/tmp/swdc-tool-cache" \
    --entrypoint=sh \
    busybox \
    -c "rm -rf /tmp/swdc-tool-cache/*"