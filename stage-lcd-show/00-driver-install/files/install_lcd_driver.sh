#!/bin/bash

cd /boot
wget http://www.lcdwiki.com/res/RaspDriver/LCD-show.tar.gz;
tar -xzf LCD-show.tar.gz;
cd LCD-show;
./LCD35-show 180
