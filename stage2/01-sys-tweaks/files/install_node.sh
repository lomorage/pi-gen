#!/bin/bash

NODE_VERSION=v9.8.0;
NPM_CACHE=/home/pi/.npm/npm-cache

# Install node.js
echo "Install node.js..."

# notice for pi zero we need armv61 version
cd /tmp;
wget https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-armv7l.tar.gz;
tar -xzf node-$NODE_VERSION-linux-armv7l.tar.gz;
rm node-$NODE_VERSION-linux-armv7l.tar.gz;
rm -rf /opt/nodejs;
mv node-$NODE_VERSION-linux-armv7l /opt/nodejs/;

ln -f -s /opt/nodejs/bin/node /sbin/node;
ln -f -s /opt/nodejs/bin/npm /sbin/npm;

npm config set unsafe-perm true
npm cache clean -f
npm config set cache $NPM_CACHE --global
npm set progress=false
rm -rf $NPM_CACHE
sudo -H -u pi bash -c "mkdir -p $NPM_CACHE"

npm install -g localtunnel
ln -f -s /opt/nodejs/bin/lt /sbin/lt;
