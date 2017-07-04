#!/bin/sh

abuild-keygen -a -n -i

cd /aports
git init
git remote add origin \
  https://github.com/alpinelinux/aports.git --no-tags
git config core.sparseCheckout true
echo 'main/nginx/' >> .git/info/sparse-checkout
git fetch --depth=1 origin master
git checkout master
git reset --hard
patch -p 1 -i /APKBUILD.patch
cd main/nginx/
abuild -k -r
