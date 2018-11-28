#!/bin/bash

dirPath=$1
if [ ! -n "$dirPath" ]; then
    echo "请输入要清理日志文件的目录"
    exit 1
fi

if [ ! -d "$dirPath" ]; then
    echo "输入的路径非目录，请检查"
    exit 1
fi

echo "开始清理文件，路径:${dirPath}"

# 定位到指定目录
cd $dirPath
currTime=`date +%s`
for file in `ls | grep "\.log"`; do
    if [ -f "$file" ]; then
        # 如果是文件则判断最后修改时间
        modifyTime=$(eval "stat -c %Y ${file}")
        diffTime=$[ $currTime - $modifyTime ]
        # 最后修改时间超过30天的
        if [ $diffTime -gt 2592000 ]; then
            echo "删除文件:${dirPath}/${file}" 
            eval "mv ${file} ${file}.bak"
        fi
    fi
done

echo "清理文件结束，路径:${dirPath}"