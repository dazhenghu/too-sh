#!/bin/bash

# $1：需要清理的路径；$2：单位"天"，清除最后修改时间在指定天数之前的文件，默认30天之前

dirPath=$1
if [ ! -n "$dirPath" ]; then
    echo "请输入要清理日志文件的目录"
    exit 1
fi

if [ ! -d "$dirPath" ]; then
    echo "输入的路径非目录，请检查"
    exit 1
fi

overdueDays=$2
if [ ! -n "$overdueDays" ]; then
    # 如果没有输入过期文件的天数值，则默认为30天
    overdueDays=30
fi

echo "开始清理文件，路径:${dirPath}"
echo "执行日期："`date`

# 定位到指定目录
filesToRm=$(eval "find ${dirPath} -mtime +${overdueDays} -type f")
for file in ${filesToRm}; do
    if [ -f "$file" ]; then
        echo "删除文件:${file}"
        #eval "mv ${file} ${file}.bak"
        eval "rm ${file}"
    fi
done

echo "清理文件结束，路径:${dirPath}"