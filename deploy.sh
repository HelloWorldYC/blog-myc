#!/usr/bin/env sh

var1=`date '+%Y-%m-%d %H:%M:%S'`

# 确保脚本抛出遇到的错误
set -e

echo '开始执行命令'

# 进入 public 文件夹
echo "执行命令：cd ./public"
cd ./public

# 把网页文件发布到 blog-myc 仓库的 gh-page 分支
echo '执行命令：git add -A'
git add -A
echo "git commit -m "
git commit -m "update blog on $var1"
echo "执行命令：git push -f https://github.com/HelloWorldYC/blog-myc.git master:gh-pages"
git push -f https://github.com/HelloWorldYC/blog-myc.git master:gh-pages

echo "回到刚才工作目录"
cd -