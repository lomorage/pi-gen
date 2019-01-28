#!/bin/bash

MAGIC_MIRROR_DIR=/home/pi/MagicMirror

echo "Cloning MagicMirror ..."
rm -rf $MAGIC_MIRROR_DIR
sudo -H -u pi bash -c "git clone --depth=1 https://github.com/MichMich/MagicMirror.git $MAGIC_MIRROR_DIR"
echo "Cloning MagicMirror Done!"

cd $MAGIC_MIRROR_DIR || exit
echo "Installing dependencies ..."

sudo -H -u pi bash -c "npm install --unsafe-perm"
echo "Dependencies installation Done!"

# Use sample config for start MagicMirror
sudo -H -u pi bash -c "cp $MAGIC_MIRROR_DIR/config/config.js.sample $MAGIC_MIRROR_DIR/config/config.js"

echo "enable at system startup..."
npm install -g pm2
ln -f -s /opt/nodejs/bin/pm2 /sbin/pm2;
su -c "/sbin/pm2 startup -u pi --hp /home/pi"
sudo -H -u pi bash -c "/sbin/pm2 start $MAGIC_MIRROR_DIR/installers/mm.sh"
sudo -H -u pi bash -c "/sbin/pm2 save"
sudo -H -u pi bash -c "/sbin/pm2 kill"
echo "enable at system startup Done!"

#on_chroot << EOF
## install custom splashscreen.
#THEME_DIR="/usr/share/plymouth/themes/lomorage"
#sudo mkdir $THEME_DIR
#
## splash.png install
## plymouth config install
## plymouth script install
##sudo plymouth-set-default-theme -R lomorage
#EOF
