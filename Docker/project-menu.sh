#!/bin/bash

# project-menu of docker-tool.sh V1.0.0

# Copyleft © 2024-2025
# https://github.com/UnkownFate/docker-tool.sh
# Last updated: 2025-01-22

# This work is licensed under GNU AGPL 3.0.
# https://github.com/UnkownFate/docker-tool.sh?tab=AGPL-3.0-1-ov-file

# 引用父脚本
source "$PARENT_SCRIPT"

# 定义菜单文本变量
project_menu_title="当前部署项目："
project_menu_text_1="新建存储卷文件夹"
project_menu_text_2="将存储卷文件夹对 http、Everyone 提权"
project_menu_text_3="拉取镜像"
project_menu_text_4="重置容器"
project_menu_text_5="导出镜像"
project_menu_text_6="备份存储卷文件夹"
project_menu_text_7="查看容器日志"
project_menu_text_8="查看容器详情"
project_menu_text_9="查看镜像详情"
project_menu_text_10="重新启动容器"
project_menu_text_11="停止容器"
project_menu_text_12="强制停止容器"
project_menu_text_13="删除容器"
project_menu_text_14="删除镜像"
project_menu_navigation="+. 刷新      -. 返回      0. 退出"

# 函数：定义菜单命令变量
function var_project_menu_command() {
  # 检查项目目录下是否有 docker-run 脚本文件
  if [ -f "$DOCKER_PROJECT_PATH/$DOCKER_PROJECT_NAME.sh" ]; then
    bash "$PARENT_SCRIPT" && var_docker_volume_folder_path
    bash "$PARENT_SCRIPT" && var_docker_volume_folder_name
    bash "$PARENT_SCRIPT" && var_docker_container_name
    bash "$PARENT_SCRIPT" && var_docker_image_name
    bash "$PARENT_SCRIPT" && var_docker_image_file_name
    declare -g project_menu_command_1="docker_volume_folder_mkdir"
    declare -g project_menu_command_2="docker_volume_folder_chmod"
    declare -g project_menu_command_3="docker_pull"
    declare -g project_menu_command_4="docker_reset"
    declare -g project_menu_command_5="docker_save"
    declare -g project_menu_command_6="docker_volume_folder_backup"
    declare -g project_menu_command_7="docker_logs"
    declare -g project_menu_command_8="docker_inspect_ps"
    declare -g project_menu_command_9="docker_inspect_images"
    declare -g project_menu_command_10="docker_restart"
    declare -g project_menu_command_11="docker_stop"
    declare -g project_menu_command_12="docker_kill"
    declare -g project_menu_command_13="docker_rm"
    declare -g project_menu_command_14="docker_rmi"
  # 检查项目目录下是否有 docker-compose 配置文件
  elif [ -f "$DOCKER_PROJECT_PATH/$DOCKER_PROJECT_NAME.yaml" ] || [ -f "$DOCKER_PROJECT_PATH/$DOCKER_PROJECT_NAME.yml" ]; then
    bash "$PARENT_SCRIPT" && var_docker_compose_volume_folder_path
    bash "$PARENT_SCRIPT" && var_docker_compose_volume_folder_name
    bash "$PARENT_SCRIPT" && var_docker_compose_container_name
    bash "$PARENT_SCRIPT" && var_docker_compose_image_name
    bash "$PARENT_SCRIPT" && var_docker_compose_image_file_name
    declare -g project_menu_command_1="docker_compose_volume_folder_mkdir"
    declare -g project_menu_command_2="docker_compose_volume_folder_chmod"
    declare -g project_menu_command_3="docker_compose_check_database_keywords"
    declare -g project_menu_command_4="docker_compose_reset"
    declare -g project_menu_command_5="docker_compose_save"
    declare -g project_menu_command_6="docker_compose_volume_folder_backup"
    declare -g project_menu_command_7="docker_compose_logs_menu"
    declare -g project_menu_command_8="docker_compose_inspect_container_menu"
    declare -g project_menu_command_9="docker_compose_inspect_image_menu"
    declare -g project_menu_command_10="docker_compose_restart"
    declare -g project_menu_command_11="docker_compose_stop"
    declare -g project_menu_command_12="docker_compose_kill"
    declare -g project_menu_command_13="docker_compose_down"
    declare -g project_menu_command_14="docker_compose_rmi_menu"
  fi
}
var_project_menu_command

# 函数：根据项目自定义菜单项动态增减变量
function var_project_custom_menu() {
  # 检查项目目录下是否有自定义菜单项脚本
  if [ -f "$DOCKER_PROJECT_PATH/$CUSTOM_MENU_ITEM_SCRIPT" ]; then
    source "$DOCKER_PROJECT_PATH/$CUSTOM_MENU_ITEM_SCRIPT"
  fi
}
var_project_custom_menu

# 函数：根据固定菜单变量、自定义菜单变量生成新的菜单变量
function var_project_menu_new() {
  # 声明两个关联数组
  declare -A texts commands
  # 收集并排序 project_menu_text_ 开头的变量
  local text_vars=($(compgen -v | grep '^project_menu_text_' | sort -V))
  for var in "${text_vars[@]}"; do
    local suffix="${var#project_menu_text_}"
    local sort_key=$(echo "$suffix" | tr '_' '.')
    texts["$sort_key"]="${!var}"
  done
  # 收集并排序 project_menu_command_ 开头的变量
  local command_vars=($(compgen -v | grep '^project_menu_command_' | sort -V))
  for var in "${command_vars[@]}"; do
    local suffix="${var#project_menu_command_}"
    local sort_key=$(echo "$suffix" | tr '_' '.')
    commands["$sort_key"]="${!var}"
  done
  # 声明全局变量 project_menu_new_text_*
  local text_counter=1
  for key in $(echo "${!texts[@]}" | tr ' ' '\n' | sort -V); do
    local new_var_name="project_menu_new_text_$text_counter"
    declare -g $new_var_name="${texts[$key]}"
    ((text_counter++))
  done
  # 声明全局变量 project_menu_new_command_*
  local command_counter=1
  for key in $(echo "${!commands[@]}" | tr ' ' '\n' | sort -V); do
    local new_var_name="project_menu_new_command_$command_counter"
    declare -g $new_var_name="${commands[$key]}"
    ((command_counter++))
  done
}
var_project_menu_new

# 函数：最终显示的项目菜单
function docker_project_menu() {
  # 初始化旧变量列表
  local project_menu_texts=()
  local max_count=0
  # 一次性收集所有以 project_menu_text_ 开头的变量
  for var in $(compgen -v | grep '^project_menu_text_' | sort -V); do
    # 提取序号，添加判断排除包含下划线的情况（即不对3_1这类带下划线数字处理）
    if [[ $var =~ ^project_menu_text_([0-9]+)$ ]]; then
      local num=${BASH_REMATCH[1]}
      project_menu_texts+=("$num")
      if (( num > max_count )); then
        max_count=$num
      fi
    fi
  done
  # 初始化新变量列表
  local project_menu_new_texts=()
  local max_new_count=0
  # 一次性收集所有以 project_menu_new_text_ 开头的变量
  for var in $(compgen -v | grep '^project_menu_new_text_' | sort -V); do
    # 提取序号
    if [[ $var =~ ^project_menu_new_text_(.*)$ ]]; then
      local new_num=${BASH_REMATCH[1]}
      project_menu_new_texts+=("$new_num")
      if (( new_num > max_new_count )); then
        max_new_count=$new_num
      fi
    fi
  done
  # 计算单列和双列菜单部分的项数
  local double_menu_count=$(( max_count - 6 )) # 双列菜单部分在 project_menu_text_6 之后
  local single_menu_count=$(( max_new_count - double_menu_count ))
  # 根据双列菜单部分项数的奇偶性计算列最大值
  local left_max_new_num  # 左侧列最大值
  if (( double_menu_count % 2 == 0 )); then
    left_max_new_num=$(( single_menu_count + double_menu_count / 2 ))
  else
    left_max_new_num=$(( single_menu_count + ( double_menu_count + 1 ) / 2 ))
  fi
  local right_max_new_num=$max_new_count # 右侧列最大值
  # 计算左侧列最大值、右侧列最大值的位数
  local left_max_digits=${#left_max_new_num}
  local right_max_digits=${#right_max_new_num}
  # 显示菜单
  while true; do
    echo ""
    echo "$project_menu_title""$DOCKER_PROJECT_NAME"
    echo "$project_menu_separator"
    # 获取要显示的项目数量，减去最后双列菜单部分项的数量
    local display_count=${#project_menu_new_texts[@]}
    local display_count=$(( display_count - double_menu_count ))
    # 循环遍历前 display_count 个项目，用于显示单列菜单部分
    for ((i = 0; i < display_count; i++)); do
      local new_num=${project_menu_new_texts[i]}
      local var_name="project_menu_new_text_$new_num"
      printf "%${left_max_digits}d. %s\n" "$new_num" "${!var_name}"
    done
    echo "$project_menu_separator"
  # -------------------------------------------
    # 显示双列菜单部分
    # 初始化两个空数组，用于存放左侧和右侧的菜单文本
    local left_texts=()
    local right_texts=()
    for var in $(compgen -v | grep '^project_menu_new_text_' | sort -V); do
      if [[ $var =~ ^project_menu_new_text_(.*)$ ]]; then
        local num=${BASH_REMATCH[1]}
        if (( num > single_menu_count && num <= left_max_new_num )); then
          local value=${!var}
          left_texts+=("$value")
        elif (( num > left_max_new_num && num <= right_max_new_num )); then
          local value=${!var}
          right_texts+=("$value")
        fi
      fi
    done
    # 初始化两个用于计算字符长度的数组
    local left_calculate_texts=()
    local right_calculate_texts=()
    # 遍历 left_texts 并替换中文字符
    for text in "${left_texts[@]}"; do
      left_calculate_texts+=("${text//[^[:ascii:]]/aa}")
    done
    # 遍历 right_texts 并替换中文字符
    for text in "${right_texts[@]}"; do
      right_calculate_texts+=("${text//[^[:ascii:]]/aa}")
    done
    # 计算左侧数组中最长的字符长度，并声明为局部变量
    local left_max_length=0
    for text in "${left_calculate_texts[@]}"; do
      local len=${#text}
      if (( len > left_max_length )); then
        left_max_length=$len
      fi
    done
    # 计算右侧数组中最长的字符长度，并声明为局部变量
    local right_max_length=0
    for text in "${right_calculate_texts[@]}"; do
      local len=${#text}
      if (( len > right_max_length )); then
        right_max_length=$len
      fi
    done
    # 按照数字从小到大排序并输出菜单文本
    for ((i = $(( single_menu_count + 1 )); i <= $left_max_new_num; i++)); do
      # 定义左侧循环变量
      local left_num=$i
      local left_num_digits=${#left_num}
      local left_num_padding=$(( left_max_digits - left_num_digits ))
      local left_dot=". "
      local left_text_var="project_menu_new_text_$left_num"
      local left_text="${!left_text_var}"
      local left_calculate_text="${left_text//[^[:ascii:]]/aa}"
      local left_text_length=${#left_calculate_text}
      local left_text_padding=$(( left_max_length - left_text_length ))
      # 定义右侧循环变量
      # 根据双列菜单项数的奇偶性定义右侧当前序号
      if (( double_menu_count % 2 == 0 )); then
        local right_num=$(( $left_num + ($double_menu_count / 2) ))
      else
        local right_num=$(( $left_num + (($double_menu_count + 1) / 2) ))
      fi
      local right_num_digits=${#right_num}
      local right_num_padding=$(( right_max_digits - right_num_digits ))
      local right_dot=". "
      local right_text_var="project_menu_new_text_$right_num"
      local right_text="${!right_text_var}"
      local right_calculate_text="${right_text//[^[:ascii:]]/aa}"
      local right_text_length=${#right_calculate_text}
      local right_text_padding=$(( right_max_length - right_text_length ))
      # 当双列菜单项数为奇数且循环到最后一行时，将右侧序号及“. ”定义为空
      if (( double_menu_count % 2!= 0 )) && [[ $i == $left_max_new_num ]]; then
        local right_num=""
        local right_dot=""
      fi
      printf "%*s%s%s%s%*s    ｜    %*s%s%s%s\n" \
        "$left_num_padding" "" "$left_num" "$left_dot" "$left_text" "$left_text_padding" "" \
        "$right_num_padding" "" "$right_num" "$right_dot" "$right_text"
    done
  # -------------------------------------------
    echo "$project_menu_separator"
    # 计算与目标序号对齐所需的空格数
    local navi_padding=$(( left_max_digits - 1 ))
    printf "%${navi_padding}s$project_menu_navigation\n" ""
    echo ""
    read choice
    # 判断输入是否为数字且在有效范围内
    if [[ $choice =~ ^[0-9]+$ ]]; then
      if [ "$choice" -gt 0 ] && [ "$choice" -le "$max_new_count" ]; then
        local var_name="project_menu_new_command_$choice"
        "${!var_name}"
      elif [ "$choice" -eq 0 ]; then
        bash "$PARENT_SCRIPT" && project_exit
      else
        bash "$PARENT_SCRIPT" && invalid_selection
      fi
    elif [ "$choice" == "+" ]; then
      bash "$PARENT_SCRIPT" && project_refresh
    elif [ "$choice" == "-" ]; then
      bash "$PARENT_SCRIPT" && project_back
    elif [ "$choice" == "." ]; then
      bash "$PARENT_SCRIPT" && print_variable
    else
      bash "$PARENT_SCRIPT" && invalid_selection
    fi
  done
}
docker_project_menu
