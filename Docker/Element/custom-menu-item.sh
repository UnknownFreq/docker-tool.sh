#!/bin/bash

# custom-menu-item of docker-tool.sh V1.0.0

# Copyleft © 2024-2025
# https://github.com/UnkownFate/docker-tool.sh
# Last updated: 2025-01-22

# This work is licensed under GNU AGPL 3.0.
# https://github.com/UnkownFate/docker-tool.sh?tab=AGPL-3.0-1-ov-file

# 函数：增加自定义菜单项
function var_custom_menu_item() {
  declare -g project_menu_text_3_1="（Dendrite 适用）生成 Dendrite 容器的服务端密钥、证书文件、证书私钥"
  declare -g project_menu_text_4_1="（Synapse 适用）创建管理员用户名、密码"
  declare -g project_menu_text_4_2="（Dendrite 适用）创建管理员用户名、密码"
# -------------------------------------------
  declare -g project_menu_command_3_1="command_3_1"
  declare -g project_menu_command_4_1="command_4_1"
  declare -g project_menu_command_4_2="command_4_2"
}

function command_3_1() {
  echo ""
  set -x
  cd $VOLUME_PATH/dendrite/config
  docker run --rm --entrypoint="" \
    -v $(pwd):/mnt \
    matrixdotorg/dendrite-monolith:latest \
    /usr/bin/generate-keys \
    -private-key /mnt/matrix_key.pem \
    -tls-cert /mnt/server.crt \
    -tls-key /mnt/server.key
  cd /
  { set +x; } >/dev/null 2>&1
}

function command_4_1() {
  echo ""
  set -x
  docker exec -it Synapse register_new_matrix_user http://localhost:8008 -c /data/homeserver.yaml
  { set +x; } >/dev/null 2>&1
  # 根据系统提示输入信息：
  # New user localpart [root]: #用户名
  # Password: #密码
  # Confirm password: 重复密码
  # Make admin [no]: yes|no
  # Sending registration request...
  # Success.
}

function command_4_2() {
  set -x
  docker exec -it Dendrite bash -c './bin/create-account --config dendrite.yaml --username'
  { set +x; } >/dev/null 2>&1
}

var_custom_menu_item
