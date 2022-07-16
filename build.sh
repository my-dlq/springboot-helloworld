#!/bin/bash

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

export WORKDIR=$( cd ` dirname $0 ` && pwd )
cd "$WORKDIR" || exit 1

mvn -version
mvn -DskipTests=true package

#Exec docker build
set -o errexit #只要出错就退出
set -o nounset #不允许引用不存在的变量
set -o pipefail #各管道内不允许出错

execute() { printf "【INFO】command: %s\n" "$*"; eval "$*";}
image_tag=""
execute "docker build --no-cache --pull -f Dockerfile" .
