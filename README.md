# docker-tool.sh
这是一个用于提高 Docker 容器操作效率的自动化 Shell 脚本，在 SSH 会话中使用，内置了常用的 Docker 功能。

# 截图
跨平台效果：

![image](https://github.com/user-attachments/assets/ce63b843-db3b-4ae4-a5fb-4d962946bce6)

一级菜单：

![image](https://github.com/user-attachments/assets/62d4b5ef-7871-4952-96c5-fe3f2800a159)

二级菜单：

![image](https://github.com/user-attachments/assets/9c74b48b-302b-45f4-b662-37a0b1e3008f)

# 测试环境
|已测试|
| :----------------: |
|Synology DSM 7.2|

|未测试|
| :---------------------------: |
|iStoreOS|
|Proxmox Virtual Environment|


# 主要功能及特性
* 针对 NAS 等场景进行 Docker 容器的全生命周期操作管理
* 集中收纳 Docker 项目到同一个菜单中，根据不同项目针对性地进行操作，如：拉取镜像、创建容器、导出镜像等
* 傻瓜化操作菜单，输入序号或字符就能自动执行对应的操作，省去了手动输入或复制粘贴命令的繁琐操作
* 根据指定目录下的 docker run 脚本或 docker-compose 配置文件自动识别对应的操作命令
* 可根据不同 Docker 项目的需要对项目菜单进行动态增减
* 菜单排版针对移动端做了适配
* 一套代码通用所有 Docker 项目，维护成本低
* 兼容了某些 Docker 项目的特殊部署方式

# 脚本文件的组成及作用
* docker-tool.sh：用于输出环境变量、展示一级菜单、执行具体的操作命令
* project-menu.sh：用于展示二级菜单
* DOCKER_RUN_FILE：针对单容器项目存储 docker run 命令
* DOCKER_COMPOSE_FILE：（非脚本）针对多容器项目存储 docker-compose 的配置信息
* custom-menu-item.sh：根据项目的需要对二级菜单进行增减

# 使用方法

1. 运行环境：你的目标设备必须已安装 Docker 和 Docker Compose，并且已经解决了镜像拉取相关的问题


2. 使用本工具的前提：建立一套有条理的 Docker 项目管理方法， 依赖特定的文件目录结构：

（1）在 NAS 或目标设备中创建一个专门管理 Docker 项目的主文件夹（以下简称“Docker 文件夹”），如：/volume1/your_path/Docker

（2）在 Docker 文件夹内为每个需要部署的 Docker 项目创建一个独立的文件夹（以下简称“项目文件夹”），如：/volume1/your_path/Docker/Jellyfin，/volume1/your_path/Docker/RustDesk，等等

（3）将 docker-tool.sh、project-menu.sh 放入 Docker 文件夹


3. 根据你的目标设备情况定义 docker-tool.sh 中的环境变量，含义说明：
```
PARENT_SCRIPT：docker-tool.sh 脚本自身的完整路径，此环境变量的值无需修改，脚本会自动处理

DOCKER_PATH：Docker 文件夹的路径，此环境变量的值无需修改，脚本会自动处理

DOCKER_RUN_FILE：用于存储 docker run 命令的脚本文件名，适用于单容器项目，需固定命名为与项目文件夹同名的 .sh 文件（此环境变量的值无需修改），如 Jellyfin.sh，并将其放入项目文件夹内

DOCKER_COMPOSE_FILE：用于存储 docker-compose 信息的配置文件名，适用于多容器项目，需固定命名为与项目文件夹同名的 .yaml 文件或 .yml 文件（此环境变量的值无需修改），如 RustDesk.yaml，并将其放入项目文件夹内

DOCKER_IMAGE_SAVE_PATH：用于导出镜像的保存路径，可自定义

VOLUME_PATH：存储卷文件夹所在目录路径，用于保存容器挂载的外置文件夹，如 /volume1/docker，可自定义

VOLUME_BACKUP_PATH：用于备份容器挂载的外置文件夹，作为目标路径，可自定义

PROJECT_MENU_SCRIPT：此变量的值应为 Docker 文件夹下的 project-menu.sh 文件名，可自定义

CUSTOM_MENU_ITEM_SCRIPT：此变量的值应为项目文件夹下的 custom-menu-item.sh 文件名，用于某些 Docker 项目对二级菜单进行增减，可自定义
```

4. 在 docker-tool.sh 中定义全局变量，含义说明：
```
docker_project_name_1：变量值应与每个项目文件夹同名，变量名称后缀按照自然数从小到大排列，如：docker_project_name_1="Jellyfin"，docker_project_name_2="RustDesk"，以此类推，直接参与生成一级菜单

special_project_name_1：变量值为特殊项目名称，此类项目为特殊部署方式，如雷池、小雅超集，变量名称后缀按照自然数从小到大排列

special_project_command_1() { ; }：这个不是变量，而是每个特殊项目所对应的执行命令，应在{ ;两个字符之间插入具体的命令，如打开雷池官方的部署脚本，或打开小雅超集的部署脚本，变量名称后缀按照自然数从小到大排列

project_column_count：一级菜单的列数，值为1或2，可根据 Docker 项目的数量设置

database_keywords：数据库镜像的关键词，用于判断 docker-compose 配置文件中是否有数据库容器
```

5. 在项目文件夹中放入 DOCKER_RUN_FILE 或 DOCKER_COMPOSE_FILE，具体举例：

（1）DOCKER_RUN_FILE：如 /volume1/your_path/Docker/Jellyfin/Jellyfin.sh
```
#!/bin/bash

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
```

（2）DOCKER_COMPOSE_FILE：就是 docker-compose 配置文件，如 /volume1/your_path/Docker/RustDeskRustDesk.yaml
```
version: '3.8'

services:

  rustdesk:
    container_name: RustDesk
    image: rustdesk/rustdesk-server-s6:latest
    restart: always
    network_mode: host
    volumes:
      - ${VOLUME_PATH}/rustdesk/db:/db
      - /etc/localtime:/etc/localtime:ro
    environment:
      - ENABLE_WEB_CLIENT=true
      - RELAY="your.domain:port"
      - ENCRYPTED_ONLY=1
      - DB_URL=/db/db_v2.sqlite3
      - KEY_PRIV="your_value"
      - KEY_PUB="your_value"

  rustdesk_api_server:
    container_name: RustDesk_API_Server
    image: kingmo888/rustdesk-api-server:master
    restart: always
    ports:
      - 21114:21114/tcp
      - 21114:21114/udp
    volumes:
      - ${VOLUME_PATH}/rustdesk_api_server/db:/rustdesk-api-server/db
      - /etc/localtime:/etc/localtime:ro
#      - /etc/timezone:/etc/timezone:ro
    environment:
      - CSRF_TRUSTED_ORIGINS="https://your.domain:port"   # 防跨域信任来源，可选
      - ID_SERVER="your.domain:port"  # Web控制端使用的ID服务器
      - ALLOW_REGISTRATION=False
```

6. 如果 Docker 项目的操作菜单需要增加独有的自定义步骤，可以在项目文件夹下增加 custom-menu-item.sh 文件，具体内容举例：

（1）增加菜单项，如聊天软件 Element 的独有步骤，菜单项的变量名以“3_1”这样的后缀命名，表示在序号为3的菜单项之后将其插入

![image](https://github.com/user-attachments/assets/c100d00e-9a1d-4dcd-80d3-b28919ac7987)

```
#!/bin/bash

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
  docker exec -it Dendrite bash -c './bin/create-account --config dendrite.yaml --jxst991059'
  { set +x; } >/dev/null 2>&1
}

var_custom_menu_item
```

（2）删除菜单项，比如 RSSHub 不涉及存储卷文件夹挂载，可将无关菜单项的变量作取消声明处理

![image](https://github.com/user-attachments/assets/71b88975-c1df-4a17-a3eb-56703a460ee1)

```
#!/bin/bash

# 取消声明不需要的菜单变量
unset -v project_menu_text_1 project_menu_command_1
unset -v project_menu_text_2 project_menu_command_2
unset -v project_menu_text_6 project_menu_command_6
```

7. 将以上文件准备完毕后，即可登录到目标设备的 SSH，然后执行以下命令，在输入完 root 密码后即可打开一级菜单：

source "/volume1/your_path/Docker/docker-tool.sh" && deployment_program

8. 其他注意事项

（1）在 DOCKER_RUN_FILE 或 DOCKER_COMPOSE_FILE 中，只有引用了环境变量 ${VOLUME_PATH} 的路径，才会参与创建和备份存储卷文件夹或进行提权操作（提权操作的代码默认为注释掉，可根据需要手动去掉注释）

（2）在 DOCKER_RUN_FILE 中，默认情况下会直接引用环境变量 $DOCKER_PROJECT_NAME 作为容器名称，如果需要将容器名称修改成其他的，在 DOCKER_RUN_FILE 中直接修改即可

（3）重置容器的含义：删除旧容器，并重新创建、运行容器

（4）Release 中包含了 Docker 项目的用例

（5）隐藏功能：输入“.”可查看当前环境中的变量，用于调试

# 版权信息
Copyleft © 2024-2025

https://github.com/UnkownFate/docker-tool.sh

Last updated: 2025-01-22


This work is licensed under GNU AGPL 3.0.

https://github.com/UnkownFate/docker-tool.sh?tab\=AGPL-3.0-1-ov-file
