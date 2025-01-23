#!/bin/bash

# DOCKER_RUN_FILE of docker-tool.sh V1.0.0

# Copyleft © 2024-2025 UnknownFreq
# https://github.com/UnknownFreq/docker-tool.sh
# Last updated: 2025-01-22

# This work is libre software and licensed under GNU AGPL 3.0.
# https://github.com/UnknownFreq/docker-tool.sh?tab=AGPL-3.0-1-ov-file

function docker_run() {

echo ""
set -x

docker run --name $DOCKER_PROJECT_NAME \
  --restart always \
  -d \
  -p 1200:1200 \
  -v /etc/localtime:/etc/localtime:ro \
  -e CACHE_EXPIRE=3600 \
  diygod/rsshub:chromium-bundled

{ set +x; } >/dev/null 2>&1

}
