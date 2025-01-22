# docker-tool.sh
这是一个用于提高 Docker 容器操作效率的自动化 Shell 脚本，在 SSH 会话中使用，内置了常用的 Docker 功能。

# 截图
一级菜单：
![图像_2025-01-22_15：09：47](assets/图像_2025-01-22_15：09：47-20250122151006-zc9dlw2.png)
二级菜单：
![图像_2025-01-22_14：23：04](assets/图像_2025-01-22_14：23：04-20250122142305-86q9wjw.png)

# 测试环境
|已测试|
| :---------------------------: |
|Synology DSM 7.2|
|未测试|
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
PARENT_SCRIPT：docker-tool.sh 脚本自身的完整路径，此环境变量的值无需修改，脚本会自动处理
DOCKER_PATH：Docker 文件夹的路径，此环境变量的值无需修改，脚本会自动处理
DOCKER_RUN_FILE：用于存储 docker run 命令的脚本文件名，适用于单容器项目，需固定命名为与项目文件夹同名的 .sh 文件（此环境变量的值无需修改），如 Jellyfin.sh，并将其放入项目文件夹内
DOCKER_COMPOSE_FILE：用于存储 docker-compose 信息的配置文件名，适用于多容器项目，需固定命名为与项目文件夹同名的 .yaml 文件或 .yml 文件（此环境变量的值无需修改），如 RustDesk.yaml，并将其放入项目文件夹内
DOCKER_IMAGE_SAVE_PATH：用于导出镜像的保存路径，可自定义
VOLUME_PATH：存储卷文件夹所在目录路径，用于保存容器挂载的外置文件夹，如 /volume1/docker，可自定义
VOLUME_BACKUP_PATH：用于备份容器挂载的外置文件夹，作为目标路径，可自定义
PROJECT_MENU_SCRIPT：此变量的值应为 Docker 文件夹下的 project-menu.sh 文件名，可自定义
CUSTOM_MENU_ITEM_SCRIPT：此变量的值应为项目文件夹下的 custom-menu-item.sh 文件名，用于某些 Docker 项目对二级菜单进行增减，可自定义

4. 在 docker-tool.sh 中定义全局变量，含义说明：
docker_project_name_1：变量值应与每个项目文件夹同名，变量名称后缀按照自然数从小到大排列，如：docker_project_name_1="Jellyfin"，docker_project_name_2="RustDesk"，以此类推，直接参与生成一级菜单
special_project_name_1：变量值为特殊项目名称，此类项目为特殊部署方式，如雷池、小雅超集，变量名称后缀按照自然数从小到大排列
special_project_command_1() { ; }：这个不是变量，而是每个特殊项目所对应的执行命令，应在{ ;两个字符之间插入具体的命令，如打开雷池官方的部署脚本，或打开小雅超集的部署脚本，变量名称后缀按照自然数从小到大排列
project_column_count：一级菜单的列数，值为1或2，可根据 Docker 项目的数量设置
database_keywords：数据库镜像的关键词，用于判断 docker-compose 配置文件中是否有数据库容器

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
