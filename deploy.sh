#!/usr/bin/env sh

var1=`date '+%Y-%m-%d %H:%M:%S'`

# 确保脚本抛出遇到的错误
set -e

echo '开始执行命令'

# 源文件发布到 blog-myc 仓库的 master 分支
echo '执行命令：git add -A'
git add -A
echo "git commit -m "
git commit -m "update blog on $var1"
echo '执行命令：git push -f git@github.com:HelloWorldYC/blog-myc.git master'
git push -f git@github.com:HelloWorldYC/blog-myc.git master



# 把网页文件发布到 blog-myc 仓库的 gh-page 分支
echo "执行命令：hexo d"
hexo d

echo "回到刚才工作目录"
cd -