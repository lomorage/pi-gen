#!/bin/bash

NODE_VERSION=9.8.0
NPM_CACHE=/home/FIRST_USER_NAME/.npm/npm-cache

# Install node.js
echo "Install node.js..."

# notice for pi zero we need armv61 version
python /sbin/node-install -v $NODE_VERSION

rm -rf $NPM_CACHE
npm config set unsafe-perm true
npm cache clean -f
npm config set cache $NPM_CACHE --global
npm set progress=false
rm -rf $NPM_CACHE
sudo -H -u FIRST_USER_NAME bash -c "mkdir -p $NPM_CACHE"

npm install -g localtunnel
ln -f -s /opt/nodejs/bin/lt /sbin/lt;
