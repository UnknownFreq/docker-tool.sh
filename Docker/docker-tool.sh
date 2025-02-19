#!/bin/bash

# 函数：版权信息
function copyleft_info() {
  echo "docker-tool.sh V1.0.2"
  echo ""
  echo "Copyleft © 2024-2025 UnknownFreq"
  echo "https://github.com/UnknownFreq/docker-tool.sh"
  echo "Last updated: 2025-02-19"
  echo ""
  echo "This work is libre software and licensed under GNU AGPL 3.0."
  echo "https://github.com/UnknownFreq/docker-tool.sh?tab=AGPL-3.0-1-ov-file"
}

# 输出环境变量
export PARENT_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")" # 获取自身路径
export DOCKER_PATH="$(dirname "$PARENT_SCRIPT")" # 获取自身所在目录路径
export DOCKER_PROJECT_PATH="$DOCKER_PATH/$DOCKER_PROJECT_NAME" # 选择具体 Docker 项目后赋值
export DOCKER_RUN_FILE="$DOCKER_PROJECT_NAME.sh" # 选择具体 Docker 项目后赋值
export DOCKER_COMPOSE_FILE="$DOCKER_PROJECT_NAME.yaml" # 选择具体 Docker 项目后赋值
export DOCKER_IMAGE_SAVE_PATH="$DOCKER_PROJECT_PATH/镜像" # 镜像导出路径，选择具体 Docker 项目后赋值，可自定义
export VOLUME_PATH="/volume1/docker" # 存储卷文件夹所在目录路径，可自定义
export VOLUME_BACKUP_PATH="/volume1/your_path/Docker/备份" # 存储卷文件夹的备份目的地路径，可自定义
export PROJECT_MENU_SCRIPT="project-menu.sh" # 项目菜单脚本的文件名，可自定义
export CUSTOM_MENU_ITEM_SCRIPT="custom-menu-item.sh" # Docker 项目的自定义菜单项脚本的文件名，可自定义

#（★维护）定义全局变量
# -------------------------------------------
docker_project_name_1="Portainer" # 以下请根据自身需要修改
docker_project_name_2="DDNS-GO"
docker_project_name_3="acme.sh"
docker_project_name_4="frps"
docker_project_name_5="frpc"
docker_project_name_6="Coturn"
docker_project_name_7="雷池"
docker_project_name_8="APISIX"
docker_project_name_9="Prometheus"
docker_project_name_10="Home Assistant"
docker_project_name_11="MinIO"
docker_project_name_12="Nextcloud"
docker_project_name_13="迅雷远程下载"
docker_project_name_14="yt-dlp-web"
docker_project_name_15="JumpServer"
docker_project_name_16="RustDesk"
docker_project_name_17="WireGuard Easy"
docker_project_name_18="memos"
docker_project_name_19="Vikunja"
docker_project_name_20="思源笔记"
docker_project_name_21="Element"
docker_project_name_22="Calibre-Web"
docker_project_name_23="wallabag"
docker_project_name_24="Tiny Tiny RSS"
docker_project_name_25="RSSHub"
docker_project_name_26="Chevereto"
docker_project_name_27="解锁网易云音乐"
docker_project_name_28="Jellyfin"
# -------------------------------------------
special_project_name_1="" # 特殊项目 1（如有需要请在""内补全项目名称，可无限添加同类变量，序号以自然数延续）
# -------------------------------------------
#special_project_command_1() { ; } # 特殊项目 1 的特殊部署方式（如有需要请在{}内的;前补全具体命令并删除前置#号，比如运行对应项目开发者制作的部署脚本，可无限添加同类变量，序号以自然数延续）
# -------------------------------------------
project_column_count="2" # 项目列表列数（1为单列，2为双列）
project_menu_separator="-------------------------------------------" # 菜单分隔线
database_keywords=("sqlite:" "mysql:" "mariadb:" "postgres:" "postgresql:" "mongodb:") # 数据库关键词，用于检查当前 Docker 项目是否涉及数据库镜像

# 函数：打印变量
function print_variable() {
  declare -p
}

# 函数：清除自身变量
function unset_variable() {
  unset -v $(compgen -v | grep '^docker_project_name_' | sort -V) database_keywords
}

# 函数：导航操作

function project_refresh() {
  exec "$(readlink -f "$0")"
  exit
}

function project_back() {
  source "$PARENT_SCRIPT" && deployment_program
  exit
}

function project_exit() {
  echo ""
  exit
}

function invalid_selection() {
  echo ""
  echo "无效的选择，请重新输入"
}

# 函数：打印单列 Docker 项目菜单（不可独立运行）
function echo_docker_project_menu_single() {
  # 计算最大序号的位数
  local max_digits=${#max_count}
  for num in "${docker_projects_num[@]}"; do
  local var_name="docker_project_name_$num"
  printf "%${max_digits}d. %s\n" "$num" "${!var_name}"
  done
  echo "$project_menu_separator"
  # 计算“刷新”前的空格数，使其与最大序号对齐
  local max_padding=$(( max_digits - 1 ))
  printf "%${max_padding}s+. 刷新      0. 退出\n" ""
}

# 函数：打印双列 Docker 项目菜单（不可独立运行）
function echo_docker_project_menu_double() {
  # 根据最大序号的奇偶性定义左侧最大序号
  if (( max_count % 2 == 0 )); then
    left_max_num=$(( max_count / 2 ))
  else
    left_max_num=$(( ( max_count + 1 ) / 2 ))
  fi
  # 定义右侧最大序号
  local right_max_num=$max_count
  # 计算左侧最大序号、右侧最大序号的位数
  local left_max_digits=${#left_max_num}
  local right_max_digits=${#right_max_num}
  # 初始化两个空数组，用于存放左侧和右侧的项目名称
  local left_names=()
  local right_names=()
  for var in $(compgen -v | grep '^docker_project_name_' | sort -V); do
    if [[ $var =~ ^docker_project_name_(.*)$ ]]; then
      local num=${BASH_REMATCH[1]}
      if (( num >= min_count && num <= left_max_num )); then
        local value=${!var}
        left_names+=("$value")
      elif (( num > left_max_num && num <= right_max_num )); then
        local value=${!var}
        right_names+=("$value")
      fi
    fi
  done
  # 初始化两个用于计算字符长度的数组
  local left_calculate_names=()
  local right_calculate_names=()
  # 遍历 left_names 并替换中文字符
  for name in "${left_names[@]}"; do
    left_calculate_names+=("${name//[^[:ascii:]]/aa}")
  done
  # 遍历 right_names 并替换中文字符
  for name in "${right_names[@]}"; do
    right_calculate_names+=("${name//[^[:ascii:]]/aa}")
  done
  # 计算左侧数组中最长的字符长度，并声明为局部变量
  local left_max_length=0
  for name in "${left_calculate_names[@]}"; do
    local len=${#name}
    if (( len > left_max_length )); then
      left_max_length=$len
    fi
  done
  # 计算右侧数组中最长的字符长度，并声明为局部变量
  local right_max_length=0
  for name in "${right_calculate_names[@]}"; do
    local len=${#name}
    if (( len > right_max_length )); then
      right_max_length=$len
    fi
  done
  # 按照数字从小到大排序并输出菜单文本
  for ((i = 1; i <= left_max_num; i++)); do
    # 检查当前数字是否在 docker_projects_num 数组中
    if [[ " ${docker_projects_num[*]} " =~ " $i " ]]; then
      # 定义左侧循环变量
      local left_num=$i
      local left_num_digits=${#left_num}
      local left_num_padding=$(( left_max_digits - left_num_digits ))
      local left_dot=". "
      local left_name_var="docker_project_name_$left_num"
      local left_name="${!left_name_var}"
      local left_calculate_name="${left_name//[^[:ascii:]]/aa}"
      local left_name_length=${#left_calculate_name}
      local left_name_padding=$(( left_max_length - left_name_length ))
      # 定义右侧循环变量
      # 根据最大序号奇偶性定义右侧当前序号
      if (( max_count % 2 == 0 )); then
        local right_num=$(( $left_num + ($max_count / 2) ))
      else
        local right_num=$(( $left_num + (($max_count + 1) / 2) ))
      fi
      local right_num_digits=${#right_num}
      local right_num_padding=$(( right_max_digits - right_num_digits ))
      local right_dot=". "
      local right_name_var="docker_project_name_$right_num"
      local right_name="${!right_name_var}"
      local right_calculate_name="${right_name//[^[:ascii:]]/aa}"
      local right_name_length=${#right_calculate_name}
      local right_name_padding=$(( right_max_length - right_name_length ))
      # 当项目总数为奇数且循环到最后一行时，将右侧序号及“. ”定义为空
      if (( max_count % 2!= 0 )) && [[ $i == $left_max_num ]]; then
        local right_num=""
        local right_dot=""
      fi
      printf "%*s%s%s%s%*s   |   %*s%s%s%s\n" \
        "$left_num_padding" "" "$left_num" "$left_dot" "$left_name" "$left_name_padding" "" \
        "$right_num_padding" "" "$right_num" "$right_dot" "$right_name"
    fi
  done
  echo "$project_menu_separator"
  # 计算“刷新”前的空格数，使其与左侧最大序号对齐
  local left_max_padding=$(( left_max_digits - 1 ))
  printf "%${left_max_padding}s+. 刷新      0. 退出\n" ""
}

# 函数：进入所选 Docker 项目的部署界面（无法独立运行）
function enter_docker_project() {
  # 获取以 special_project_name_ 开头的变量名数组
  local special_project_names=($(compgen -v | grep '^special_project_name_'))
  # 获取以 special_project_command_ 开头的函数名数组
  local special_project_commands=($(compgen -A function | grep '^special_project_command_'))
  # 获取变量名数组的长度，用于循环控制
  local num_projects=${#special_project_names[@]}
  for ((i = 0; i < num_projects; i++)); do
    current_name="${special_project_names[$i]}"
    current_command="${special_project_commands[$i]}"
    local name_value="${!current_name}"
    if [ "$DOCKER_PROJECT_NAME" == "$name_value" ]; then
      echo ""
      # 进入所选特殊项目的部署界面
      $current_command
      break
    else
      # 进入常规部署方式的 Docker 项目菜单（常规部署方式：docker cli 或 docker-compose）
      bash "$DOCKER_PATH/$PROJECT_MENU_SCRIPT"
    fi
  done
}

# 函数：部署程序
function deployment_program() {
  # 检查是否已获取 root 权限
  if [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo "请输入密码获取 root 权限："
    sudo -i
  else
    # 部署程序菜单
    # 初始化变量列表
    local docker_projects_num=()
    local max_count=0
    # 一次性收集所有以 docker_project_name_ 开头的变量
    for var in $(compgen -v | grep '^docker_project_name_' | sort -V); do
      # 提取最小序号和最大序号
      if [[ $var =~ ^docker_project_name_(.*)$ ]]; then
        local num=${BASH_REMATCH[1]}
        docker_projects_num+=("$num")
        if (( num < min_count )) || (( min_count == 0 )); then
          min_count=$num
        fi
        if (( num > max_count )); then
          max_count=$num
        fi
      fi
    done
    # 显示菜单
    while true; do
      echo ""
      echo "$project_menu_separator"
      copyleft_info
      echo ""
      echo "DiskStation Docker 部署程序："
      echo "$project_menu_separator"
      # 显示所有项目（单列）
      if [[ $project_column_count == "1" ]]; then
        echo_docker_project_menu_single
      # 显示所有项目（双列）
      elif [[ $project_column_count == "2" ]]; then
        echo_docker_project_menu_double
      fi
      echo ""
      read choice
      # 判断输入是否为数字且在有效范围内
      if [[ $choice =~ ^[0-9]+$ ]]; then
        if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_count" ]; then
          local var_name="docker_project_name_$choice"
          # 将所选 Docker 项目的名称输出为全局变量
          export DOCKER_PROJECT_NAME="${!var_name}"
          # 进入所选 Docker 项目的部署界面
          enter_docker_project
          break
        elif [ "$choice" -eq 0 ]; then
          echo ""
          break
        else
          invalid_selection
        fi
      elif [ "$choice" == "+" ]; then
        # 重新加载脚本并刷新菜单
        unset_variable
        source "$PARENT_SCRIPT" && deployment_program
        break
      elif [ "$choice" == "." ]; then
        print_variable
      else
        invalid_selection
      fi
    done
  fi
}

# 函数：docker 系列命令

function var_docker_volume_folder_path() {
  local volume_path="${VOLUME_PATH}"
  local unique_paths=()
  local seen=()
  local index=1  # 初始化索引
  # 使用 mapfile 一次性读取所有行
  mapfile -t lines < "$DOCKER_PROJECT_PATH/$DOCKER_RUN_FILE"
  for line in "${lines[@]}"; do
    # 使用 Bash 内置的正则表达式匹配 ${VOLUME_PATH} 开头到第一个 ":" 的部分
    if [[ $line =~ \$\{VOLUME_PATH\}([^:]+) ]]; then
      local match="${volume_path}${BASH_REMATCH[1]}"
      # 去除匹配部分末尾的 ":"
      if [[ $match == *':' ]]; then
        match="${match%:}"
      fi
      # 检查最后一个 "/" 后是否有 "."
      if [[ "$match" == *"."* ]]; then
        # 删除最后一个 "/" 及其后面的部分
        match="${match%/*}"
      fi
      # 去除可能的 "\" 和 引号，并进行去重
      clean_path="${match//\\//}"  # 移除反斜杠（如果有）
      clean_path="${clean_path//\"/}" # 移除双引号
      clean_path="${clean_path//\'/}" # 移除单引号
      if [[ ! " ${seen[@]} " =~ " ${clean_path} " ]]; then
        seen+=("$clean_path")
        unique_paths+=("$match")  # 保留包含 ${VOLUME_PATH} 的路径
      fi
    fi
  done
  # 输出为全局变量，使用指定的声明方式
  for path in "${unique_paths[@]}"; do
    declare -g volume_folder_path_$index="$path"
    index=$(( index + 1 ))
  done
  # 清理局部变量
  unset -v lines line clean_path path
}

function var_docker_volume_folder_name() {
  # 使用关联数组来存储唯一的文件夹名称
  declare -A unique_volumes
  local index=1
  # 生成所有以 volume_folder_path_ 开头的变量名，并按自然数排序
  for var in $(compgen -v | grep '^volume_folder_path_' | sort -V); do
    # 获取变量的值
    local value="${!var}"
    # 使用参数展开一次性提取文件夹名称
    local folder="${value#*$VOLUME_PATH/}"
    folder="${folder%%/*}"
    # 如果提取到的folder非空且未重复，则添加到关联数组
    if [[ -n "$folder" && -z "${unique_volumes["$folder"]}" ]]; then
      unique_volumes["$folder"]=1
      # 定义全局变量
      declare -g volume_folder_name="$folder"
    fi
  done
  # 清理局部变量
  unset -v var
}

function var_docker_container_name() {
  # 提取 --name 后的内容，不转义 $
  local extracted_name=$(grep -oP '(?<=--name\s)[^ ]+' "$DOCKER_PROJECT_PATH/$DOCKER_RUN_FILE")
  # 初始化全局变量
  declare -g docker_container_name=""
  # 检查提取的内容是否是变量引用
  if [[ $extracted_name == \$* ]]; then
    # 使用 eval 获取变量的值，注意安全风险
    docker_container_name=$(eval echo "$extracted_name")
  else
    # 直接使用提取的内容
    docker_container_name="$extracted_name"
  fi
}

function var_docker_image_name() {
  local docker_script="$DOCKER_PROJECT_PATH/$DOCKER_RUN_FILE"
  # 使用grep查找包含"docker run"的行号
  local docker_run_line
  docker_run_line=$(grep -n "docker run" "$docker_script" | cut -d: -f1)
  # 从 docker run 的下一行开始查找第一个包含"+x;"的行号
  local double_semicolon_line=0
  local start_line=$(( docker_run_line + 1 ))
  local line_count=0
  while IFS= read -r line; do
    line_count=$(( line_count + 1 ))
    if [ $line_count -ge $start_line ]; then
      if [[ $line == *"+x;"* ]]; then
        double_semicolon_line=$line_count
        break
      fi
    fi
  done < "$docker_script"
  # 计算目标行号
  local target_line_number=$(( double_semicolon_line - 2 ))
  # 检查行号是否有效
  # 使用 sed 打印目标行内容
  local target_line
  target_line=$(sed -n "${target_line_number}p" "$docker_script")
  # 使用 grep 查找首个左右相邻都是空格的文本
  local matched_text
  matched_text=$(echo "$target_line" | grep -oP '\s+\S+\s+' | head -n1)
  local final_text
  if [[ -n "$matched_text" ]]; then
    # 去除匹配文本的前后空格
    final_text=$(echo "$matched_text" | sed 's/^\s*//;s/\s*$//')
  else
    # 如果没有找到匹配的文本，则去除整个文本的所有空格后输出
    final_text=$(echo "$target_line" | tr -d '[:space:]')
  fi
  # 使用 declare 声明全局变量
  declare -g docker_image_name="$final_text"
  return 0
}

function var_docker_image_file_name() {
  # 获取 docker_image_name 的值
  local image_name="${docker_image_name}"
  # 将 / 和 : 替换为 _
  local modified_name="${image_name//\//_}"
  modified_name="${modified_name//:/_}"
  # 在最后一个 _ 后的内容左右增加 ()
  if [[ "$docker_image_name" == *:* ]] && [[ "$modified_name" == *_* ]]; then
    modified_name="${modified_name%_*}_(${modified_name##*_})"
  fi
  # 在最终处理的文本后增加 .tar
  modified_name="${modified_name}.tar"
  # 使用 declare 声明全局变量 docker_image_file_name
  declare -g docker_image_file_name="$modified_name"
}

function docker_volume_folder_mkdir() {
  echo ""
  # 使用数组来存储变量名
  local volume_folder_paths=($(compgen -v | grep '^volume_folder_path_' | sort -V))
  # 循环遍历排序后的变量名数组并输出创建文件夹命令
  for var in "${volume_folder_paths[@]}"; do
    folder_path="${!var}"
    set -x
    mkdir -p "$folder_path"
    { set +x; } >/dev/null 2>&1
  done
  # 清理局部变量
  unset -v var folder_path
}

function docker_volume_folder_chmod() {
  echo ""
  set -x
#  chmod -R o+rwx $VOLUME_PATH/$volume_folder_name
  { set +x; } >/dev/null 2>&1
}

function docker_pull() {
  echo ""
  set -x
  docker pull $docker_image_name
  { set +x; } >/dev/null 2>&1
}

function docker_reset() {
  docker_stop
  docker_rm
  source "$DOCKER_PROJECT_PATH/$DOCKER_RUN_FILE" && docker_run
}

function docker_save() {
  mkdir -p "$DOCKER_IMAGE_SAVE_PATH"
  # 删除旧镜像（慎用）
#  echo ""
#  set -x
#  rm -rf "$DOCKER_IMAGE_SAVE_PATH/*"
#  { set +x; } >/dev/null 2>&1
  echo ""
  echo "导出中..."
  echo ""
  set -x
  docker save -o "$DOCKER_IMAGE_SAVE_PATH/$docker_image_file_name" $docker_image_name
  { set +x; } >/dev/null 2>&1
  echo ""
  echo "导出成功！"
}

function docker_volume_folder_backup() {
  mkdir -p "$VOLUME_BACKUP_PATH/$DOCKER_PROJECT_NAME"
  echo ""
  set -x
  cd "$VOLUME_PATH"
  { set +x; } >/dev/null 2>&1
  echo ""
  echo "备份中..."
  echo ""
  set -x
  if zip -r "${VOLUME_BACKUP_PATH}/${DOCKER_PROJECT_NAME}/${DOCKER_PROJECT_NAME}.zip" "$volume_folder_name" >/dev/null 2>&1; then
    {
      { set +x; } >/dev/null 2>&1
      echo ""
      echo "备份成功！"
    }
  else
    {
      { set +x; } >/dev/null 2>&1
      echo ""
      echo "备份失败！"
    }
  fi
  echo ""
  set -x
  cd /
  { set +x; } >/dev/null 2>&1
}

function docker_logs() {
  echo ""
  set -x
  docker logs -t --tail 250 $docker_container_name
  { set +x; } >/dev/null 2>&1
}

function docker_inspect_ps() {
  echo ""
  set -x
  docker inspect $docker_container_name
  { set +x; } >/dev/null 2>&1
  echo ""
  set -x
  docker ps -a -f "name=$docker_container_name"
  { set +x; } >/dev/null 2>&1
}

function docker_inspect_images() {
  echo ""
  set -x
  docker inspect $docker_image_name
  { set +x; } >/dev/null 2>&1
  echo ""
  set -x
  docker images $docker_image_name
  { set +x; } >/dev/null 2>&1
}

function docker_restart() {
  echo ""
  set -x
  docker restart $docker_container_name
  { set +x; } >/dev/null 2>&1
}

function docker_stop() {
  echo ""
  set -x
  docker stop $docker_container_name
  { set +x; } >/dev/null 2>&1
}

function docker_kill() {
  echo ""
  set -x
  docker kill $docker_container_name
  { set +x; } >/dev/null 2>&1
}

function docker_rm() {
  echo ""
  set -x
  docker rm $docker_container_name
  { set +x; } >/dev/null 2>&1
}

function docker_rmi() {
  echo ""
  set -x
  docker rmi $docker_image_name
  { set +x; } >/dev/null 2>&1
}

# 函数：docker-compose 系列命令

function var_docker_compose_volume_folder_path() {
  local volume_path="${VOLUME_PATH}"
  local unique_paths=()
  local seen=()
  local index=1  # 初始化索引
  # 使用 mapfile 一次性读取所有行
  mapfile -t lines < "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE"
  for line in "${lines[@]}"; do
    # 使用 Bash 内置的正则表达式匹配 ${VOLUME_PATH} 开头到第一个 ":" 的部分
    if [[ $line =~ \$\{VOLUME_PATH\}([^:]+) ]]; then
      local match="${volume_path}${BASH_REMATCH[1]}"
      # 去除匹配部分末尾的 ":"
      if [[ $match == *':' ]]; then
        match="${match%:}"
      fi
      # 检查最后一个 "/" 后是否有 "."
      if [[ "$match" == *"."* ]]; then
        # 删除最后一个 "/" 及其后面的部分
        match="${match%/*}"
      fi
      # 去除可能的 "\" 和 引号，并进行去重
      clean_path="${match//\\//}"  # 移除反斜杠（如果有）
      clean_path="${clean_path//\"/}" # 移除双引号
      clean_path="${clean_path//\'/}" # 移除单引号
      if [[ ! " ${seen[@]} " =~ " ${clean_path} " ]]; then
        seen+=("$clean_path")
        unique_paths+=("$match")  # 保留包含 ${VOLUME_PATH} 的路径
      fi
    fi
  done
  # 输出为全局变量，使用指定的声明方式
  for path in "${unique_paths[@]}"; do
    declare -g volume_folder_path_$index="$path"
    index=$(( index + 1 ))
  done
  # 清理局部变量
  unset -v lines line clean_path path
}

function var_docker_compose_volume_folder_name() {
  # 使用关联数组来存储唯一的文件夹名称
  declare -A unique_volumes
  local index=1
  # 生成所有以 volume_folder_path_ 开头的变量名，并按自然数排序
  for var in $(compgen -v | grep '^volume_folder_path_' | sort -V); do
    # 获取变量的值
    local value="${!var}"
    # 使用参数展开一次性提取文件夹名称
    local folder="${value#*$VOLUME_PATH/}"
    folder="${folder%%/*}"
    # 如果提取到的folder非空且未重复，则添加到关联数组
    if [[ -n "$folder" && -z "${unique_volumes["$folder"]}" ]]; then
      unique_volumes["$folder"]=1
      # 定义全局变量
      declare -g volume_folder_name_$index="$folder"
      index=$(( index + 1 ))
    fi
  done
  # 清理局部变量
  unset -v var
}

function var_docker_compose_container_name() {
  local container_names=()
  # 直接读取 Docker Compose 文件的所有行
  mapfile -t file_lines < "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE"
  # 使用关联数组记录已添加的容器名称，以去重
  declare -A added_names
  # 遍历每一行，查找 container_name 后的所有文本，忽略注释部分
  for line in "${file_lines[@]}"; do
    # 移除行内注释（如果有）
    line=${line%%#*}
    # 使用正则表达式匹配 container_name 后的所有内容，直到行尾
    if [[ $line =~ container_name[[:space:]]*[:=][[:space:]]*([^[:space:]]+) ]]; then
      local container_name="${BASH_REMATCH[1]}"
      # 如果不为空且尚未添加，则添加到列表中
      if [[ -n "$container_name" && -z "${added_names["$container_name"]}" ]]; then
        container_names+=("$container_name")
        added_names["$container_name"]=1
      fi
    fi
  done
  # 将去重后的容器名称按顺序存储为全局变量
  local index=1
  for name in "${container_names[@]}"; do
    declare -g docker_container_name_$index="$name"
    index=$(( index + 1 ))
  done
  # 清理局部变量
  unset -v file_lines line name index
}

function var_docker_compose_image_name() {
  local image_names=()
  # 直接读取 Docker Compose 文件的所有行
  mapfile -t file_lines < "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE"
  # 使用关联数组记录已添加的容器名称，以去重
  declare -A added_names
  # 遍历每一行，查找 image 后的所有文本，忽略注释部分
  for line in "${file_lines[@]}"; do
    # 移除行内注释（如果有）
    line=${line%%#*}
    # 使用正则表达式匹配 image 后的所有内容，直到行尾
    if [[ $line =~ image[[:space:]]*[:=][[:space:]]*([^[:space:]]+) ]]; then
      local image="${BASH_REMATCH[1]}"
      # 如果不为空且尚未添加，则添加到列表中
      if [[ -n "$image" && -z "${added_names["$image"]}" ]]; then
        image_names+=("$image")
        added_names["$image"]=1
      fi
    fi
  done
  # 将去重后的容器名称按顺序存储为全局变量
  local index=1
  for name in "${image_names[@]}"; do
    declare -g docker_image_name_$index="$name"
    index=$(( index + 1 ))
  done
  # 清理局部变量
  unset -v file_lines line name index
}

function var_docker_compose_image_file_name() {
  local index=1
  # 遍历所有以 docker_image_name_ 开头的变量
  for var in $(compgen -v | grep '^docker_image_name_' | sort -V); do
    # 获取变量的值
    local value="${!var}"
    # 将值中的 / 和 : 替换为 _
    image_file_name="${value//\//_}"
    image_file_name="${image_file_name//:/_}"
    # 在最后一个 _ 后的内容左右增加 ()
    if [[ "$value" == *:* ]] && [[ "$image_file_name" == *_* ]]; then
      image_file_name="${image_file_name%_*}_(${image_file_name##*_})"
    fi
    # 添加 .tar 后缀
    image_file_name="${image_file_name}.tar"
    # 使用 declare 声明全局变量
    declare -g docker_image_file_name_$index="$image_file_name"
    # 增加索引以用于下一个变量
    index=$(( index + 1 ))
  done
  # 清理局部变量
  unset -v var image_file_name
}

function docker_compose_volume_folder_mkdir() {
  docker_volume_folder_mkdir
}

function docker_compose_volume_folder_chmod() {
  echo ""
  # 使用数组来存储变量名
  local volume_folder_names=($(compgen -v | grep '^volume_folder_name_' | sort -V))
  # 循环遍历排序后的变量名数组并输出 chmod 命令
  for var in "${volume_folder_names[@]}"; do
    folder_name="${!var}"
    set -x
#    chmod -R o+rwx "$VOLUME_PATH/$folder_name"
    { set +x; } >/dev/null 2>&1
  done
  # 清理局部变量
  unset -v var folder_name
}

function docker_compose_pull() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" pull
  { set +x; } >/dev/null 2>&1
}

function docker_pull_without_database_image() {
  # 查找所有以指定前缀开头的变量名
  local image_vars=$(compgen -v | grep '^docker_image_name_' | sort -V)
  # 遍历找到的变量名，获取真实镜像并排除数据库镜像后拉取，同时控制输出格式
  for var in $image_vars; do
    local docker_image_name=${!var}
    local should_pull=true
    for keyword in "${database_keywords[@]}"; do
      if [[ $docker_image_name == *$keyword* ]]; then
        local should_pull=false
        break
      fi
    done
    if [ $should_pull == true ]; then
      echo ""
      set -x
      docker pull $docker_image_name
      { set +x; } >/dev/null 2>&1
    fi
  done
  # 清理局部变量
  unset -v var keyword
}

function docker_compose_pull_dialog_box() {
  while true; do
    echo ""
    echo "即将拉取，是否拉取数据库镜像？"
    echo "$project_menu_separator"
    printf "%${navi_padding}s 1. 是        2. 否       -. 返回\n" "" # $navi_padding 来自于项目菜单
    echo ""
    read choice
    case $choice in
      1)
        docker_compose_pull
        break
        ;;
      2)
        docker_pull_without_database_image
        break
        ;;
      -)
        project_refresh
        ;;
      *)
        invalid_selection
        ;;
    esac
  done
}

function docker_compose_check_database_keywords() {
  # 查找所有以指定前缀开头的变量名
  local image_vars=$(compgen -v | grep '^docker_image_name_' | sort -V)
  # 将查找到的变量名按换行符分割成数组，方便遍历
  IFS=$'\n' read -r -d '' -a image_vars_array <<< "$image_vars"
  # 标记是否找到匹配的关键词，初始值设为 false，代表整体匹配情况
  local check=false
  # 遍历查找到的每一个变量名
  for var_name in "${image_vars_array[@]}"; do
    # 获取变量的值
    local var_value="${!var_name}"
    # 遍历 database_keywords 数组中的每个关键词
    for keyword in "${database_keywords[@]}"; do
      # 检查变量的值是否包含当前关键词
      if [[ $var_value == *"$keyword"* ]]; then
        check=true
        break
      fi
    done
    # 这里不根据单个变量的匹配情况执行不同操作，而是继续检查下一个变量
  done
  # 根据最终整体匹配情况来执行不同操作
  if [ $check = true ]; then
    docker_compose_pull_dialog_box
  else
    docker_compose_pull
  fi
}

function docker_compose_reset() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" down
  { set +x; } >/dev/null 2>&1
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" up -d
  { set +x; } >/dev/null 2>&1
}

function docker_compose_save() {
  mkdir -p "$DOCKER_IMAGE_SAVE_PATH"
  # 删除旧镜像（慎用）
#  echo ""
#  set -x
#  rm -rf "$DOCKER_IMAGE_SAVE_PATH/*"
#  { set +x; } >/dev/null 2>&1
  echo ""
  echo "导出中..."
  # 循环查找所有符合前缀的变量并执行 docker save 操作
  for var in $(compgen -v | grep '^docker_image_name_' | sort -V); do
    # 获取变量名去掉前缀后的序号部分
    local index=${var#"docker_image_name_"}
    # 构造对应的文件名变量名
    local file_name_var="docker_image_file_name_$index"
    # 使用间接引用获取镜像变量和文件名变量的值
    local docker_image_name=${!var}
    local docker_image_file_name=${!file_name_var}
    # 执行 docker save 命令
    echo ""
    set -x
    docker save -o "$DOCKER_IMAGE_SAVE_PATH/$docker_image_file_name" $docker_image_name
    { set +x; } >/dev/null 2>&1
  done
  # 清理局部变量
  unset -v var
  echo ""
  echo "导出成功！"
}

function docker_compose_volume_folder_backup() {
  mkdir -p "$VOLUME_BACKUP_PATH/$DOCKER_PROJECT_NAME"
  echo ""
  set -x
  cd "$VOLUME_PATH"
  { set +x; } >/dev/null 2>&1
  echo ""
  echo "备份中..."
  echo ""
  # 查找所有以指定前缀开头的变量名
  local folder_vars=$(compgen -v | grep '^volume_folder_name_' | sort -V)
  # 提取真实的文件夹名称并传递给 zip 命令进行打包
  local zip_args=""
  for var in $folder_vars; do
    local folder_name=${!var}
    local zip_args="$zip_args $folder_name"
  done
  set -x
  if zip -r "${VOLUME_BACKUP_PATH}/${DOCKER_PROJECT_NAME}/${DOCKER_PROJECT_NAME}.zip" $zip_args >/dev/null 2>&1; then
    {
      { set +x; } >/dev/null 2>&1
      echo ""
      echo "备份成功！"
    }
  else
    {
      { set +x; } >/dev/null 2>&1
      echo ""
      echo "备份失败！"
    }
  fi
  echo ""
  set -x
  cd /
  { set +x; } >/dev/null 2>&1
  # 清理局部变量
  unset -v var
}

function docker_compose_logs_menu() {
  # 初始化变量列表
  local docker_containers=()
  local max_count=0
  # 一次性收集所有以 docker_container_name_ 开头的变量
  for var in $(compgen -v | grep '^docker_container_name_' | sort -V); do
    # 提取序号
    if [[ $var =~ ^docker_container_name_(.*)$ ]]; then
      local num=${BASH_REMATCH[1]}
      docker_containers+=("$num")
      if (( num > max_count )); then
        max_count=$num
      fi
    fi
  done
  # 计算最大序号的位数
  local max_digits=${#max_count}
  # 显示菜单
  while true; do
    echo ""
    echo "$project_menu_text_7："
    echo "$project_menu_separator"
    # 显示所有项目
    for num in "${docker_containers[@]}"; do
      local var_name="docker_container_name_$num"
      printf "%${max_digits}d. %s\n" "$num" "${!var_name}"
    done
    # 计算“返回”前的空格数，使其与最大序号对齐
    local padding=$(( max_digits - 1 ))
    echo "$project_menu_separator"
    printf "%${padding}s-. 返回\n" ""
    echo ""
    read choice
    # 判断输入是否为数字且在有效范围内
    if [[ $choice =~ ^[0-9]+$ ]]; then
      if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_count" ]; then
        local var_name="docker_container_name_$choice"
        echo ""
        set -x
        docker logs -t --tail 250 ${!var_name}
        { set +x; } >/dev/null 2>&1
      else
        invalid_selection
      fi
    elif [ "$choice" == "-" ]; then
      # 清理局部变量
      unset -v var
      break
    else
      invalid_selection
    fi
  done
}

function docker_compose_inspect_container_menu() {
  # 初始化变量列表
  local docker_containers=()
  local max_count=0
  # 一次性收集所有以 docker_container_name_ 开头的变量
  for var in $(compgen -v | grep '^docker_container_name_' | sort -V); do
    # 提取序号
    if [[ $var =~ ^docker_container_name_(.*)$ ]]; then
      local num=${BASH_REMATCH[1]}
      docker_containers+=("$num")
      if (( num > max_count )); then
        max_count=$num
      fi
    fi
  done
  # 计算最大序号的位数
  local max_digits=${#max_count}
  # 显示菜单
  while true; do
    echo ""
    set -x
    docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" ps -a
    { set +x; } >/dev/null 2>&1
    echo ""
    echo "$project_menu_text_8："
    echo "$project_menu_separator"
    # 显示所有项目
    for num in "${docker_containers[@]}"; do
      local var_name="docker_container_name_$num"
      printf "%${max_digits}d. %s\n" "$num" "${!var_name}"
    done
    # 计算“返回”前的空格数，使其与最大序号对齐
    local padding=$(( max_digits - 1 ))
    echo "$project_menu_separator"
    printf "%${padding}s-. 返回\n" ""
    echo ""
    read choice
    # 判断输入是否为数字且在有效范围内
    if [[ $choice =~ ^[0-9]+$ ]]; then
      if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_count" ]; then
        local var_name="docker_container_name_$choice"
        echo ""
        set -x
        docker inspect ${!var_name}
        { set +x; } >/dev/null 2>&1
      else
        invalid_selection
      fi
    elif [ "$choice" == "-" ]; then
      # 清理局部变量
      unset -v var
      break
    else
      invalid_selection
    fi
  done
}

function docker_compose_inspect_image_menu() {
  # 初始化变量列表
  local docker_images=()
  local max_count=0
  # 一次性收集所有以 docker_image_name_ 开头的变量
  for var in $(compgen -v | grep '^docker_image_name_' | sort -V); do
    # 提取序号
    if [[ $var =~ ^docker_image_name_(.*)$ ]]; then
      local num=${BASH_REMATCH[1]}
      docker_images+=("$num")
      if (( num > max_count )); then
        max_count=$num
      fi
    fi
  done
  # 计算最大序号的位数
  local max_digits=${#max_count}
  # 显示菜单
  while true; do
    echo ""
    set -x
    docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" images
    { set +x; } >/dev/null 2>&1
    echo ""
    echo "$project_menu_text_9："
    echo "$project_menu_separator"
    # 显示所有项目
    for num in "${docker_images[@]}"; do
      local var_name="docker_image_name_$num"
      printf "%${max_digits}d. %s\n" "$num" "${!var_name}"
    done
    # 计算“返回”前的空格数，使其与最大序号对齐
    local padding=$(( max_digits - 1 ))
    echo "$project_menu_separator"
    printf "%${padding}s-. 返回\n" ""
    echo ""
    read choice
    # 判断输入是否为数字且在有效范围内
    if [[ $choice =~ ^[0-9]+$ ]]; then
      if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_count" ]; then
        local var_name="docker_image_name_$choice"
        echo ""
        set -x
        docker inspect ${!var_name}
        { set +x; } >/dev/null 2>&1
      else
        invalid_selection
      fi
    elif [ "$choice" == "-" ]; then
      # 清理局部变量
      unset -v var
      break
    else
      invalid_selection
    fi
  done
}

function docker_compose_restart() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" restart
  { set +x; } >/dev/null 2>&1
}

function docker_compose_stop() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" stop
  { set +x; } >/dev/null 2>&1
}

function docker_compose_kill() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" kill
  { set +x; } >/dev/null 2>&1
}

function docker_compose_down() {
  echo ""
  set -x
  docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" down
  { set +x; } >/dev/null 2>&1
}

function docker_compose_rmi_menu() {
  # 初始化变量列表
  local docker_images=()
  local max_count=0
  # 一次性收集所有以 docker_image_name_ 开头的变量
  for var in $(compgen -v | grep '^docker_image_name_' | sort -V); do
    # 提取序号
    if [[ $var =~ ^docker_image_name_(.*)$ ]]; then
      local num=${BASH_REMATCH[1]}
      docker_images+=("$num")
      if (( num > max_count )); then
        max_count=$num
      fi
    fi
  done
  # 定义最大序号
  local max_num=$(( max_count + 1 ))
  # 计算最大序号的位数
  local max_digits=${#max_num}
  # 显示菜单
  while true; do
    echo ""
    set -x
    docker-compose -f "$DOCKER_PROJECT_PATH/$DOCKER_COMPOSE_FILE" images
    { set +x; } >/dev/null 2>&1
    echo ""
    echo "$project_menu_text_14："
    echo "$project_menu_separator"
    # 显示所有项目
    for num in "${docker_images[@]}"; do
      local var_name="docker_image_name_$num"
      printf "%${max_digits}d. %s\n" "$num" "${!var_name}"
    done
    echo "$max_num." "删除全部镜像"
    # 计算“返回”前的空格数，使其与最大序号对齐
    local padding=$(( max_digits - 1 ))
    echo "$project_menu_separator"
    printf "%${padding}s-. 返回\n" ""
    echo ""
    read choice
    # 判断输入是否为数字且在有效范围内
    if [[ $choice =~ ^[0-9]+$ ]]; then
      if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_count" ]; then
        local var_name="docker_image_name_$choice"
        echo ""
        set -x
        docker rmi "${!var_name}"
        { set +x; } >/dev/null 2>&1
      elif [ "$choice" == "$max_num" ]; then
        # 查找所有以指定前缀开头的变量名
        local image_vars=$(compgen -v | grep '^docker_image_name_' | sort -V)
        # 遍历找到的变量名，逐个删除镜像
        for var in $image_vars; do
          local docker_image_name=${!var}
          echo ""
          set -x
          docker rmi $docker_image_name
          { set +x; } >/dev/null 2>&1
        done
      else
        invalid_selection
      fi
    elif [ "$choice" == "-" ]; then
      # 清理局部变量
      unset -v var
      break
    else
      invalid_selection
    fi
  done
}
