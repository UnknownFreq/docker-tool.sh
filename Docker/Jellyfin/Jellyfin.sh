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
  --user 1000:1000 \
  -p 8096:8096 \
  -p 8920:8920 \
  -v ${VOLUME_PATH}/jellyfin/config:/config \
  -v ${VOLUME_PATH}/jellyfin/cache:/cache \
  -v /etc/localtime:/etc/localtime:ro \
  --mount type=bind,source=/volume1/video,target=/video,readonly \
  nyanmisaka/jellyfin:latest

{ set +x; } >/dev/null 2>&1

}
