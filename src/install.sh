#!/bin/sh
# Copyright 2023 Data Walker
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### install all the packages at once
pkg install -y virtualbox-ose-additions \
    xorg lightdm lightdm-gtk-greeter xfce firefox \
    doas nano vim curl

### setup boot
# remove 10 second wait during booting, you can still press buttons before the boot menu to use the boot menu
cat >> /boot/loader.conf <<EOF
autoboot_delay="0"
EOF

### setup lightdm and lightdm background image
sysrc lightdm_enable=YES
cp aesthetic.jpg /usr/local/share/backgrounds/aesthetic.jpg
cat >> /usr/local/etc/lightdm/lightdm-gtk-greeter.conf <<EOF
background = /usr/local/share/backgrounds/aesthetic.jpg
cursor-theme-name = Adwaita
cursor-theme-size = 24
EOF

### setup xfce defaults
# create separate xdg
mv /usr/local/etc/xdg /usr/local/etc/xdg-backup
cp -r xdg /usr/local/etc/xdg

# remove all backgrounds and link default to my background
# might at some point build XFCE myself with the default changed, but this will work for now
rm -rf /usr/local/share/backgrounds/xfce/
mkdir -p /usr/local/share/backgrounds/xfce/
ln -s /usr/local/share/backgrounds/aesthetic.jpg /usr/local/share/backgrounds/xfce/xfce-shapes.svg

# setup proc filesystem
cat >> /etc/fstab <<EOF
proc                    /proc           procfs  rw              0       0
EOF

# driver setup
sysrc hald_enable=YES
sysrc dbus_enable=YES
dbus-uuidgen --ensure

### change default services
sysrc ntpd_enable=YES
sysrc ntpdate_enable=YES
sysrc sshd_enable=NO

### setup virtualbox stuff
# setup vbox service
# life advice: if you want your stuff to work by default don't use something written by oracle
# virtualbox errors if you enable vboxguest and don't add wheel to the user
# I don't want wheel on user so we'll just disable it
sysrc vboxguest_enable=NO
# but we can enable vboxservice
sysrc vboxservice_enable=YES
sysrc vboxservice_flags=--disable-timesync

### miscellaneous

# disable console
cat > /etc/ttys <<EOF
#no ttys because we want this to be a desktop only
#ttyv0   "/usr/libexec/getty Pc"         xterm   onifexists secure
EOF

### setup user
# create user theophilus
# add theophilus to video group so he can use x11
pw user add -n theophilus -c 'Theophilus' -G video -w yes -m

### setup doas
cat >> /usr/local/etc/doas.conf <<EOF
permit theophilus as root cmd /usr/bin/su
EOF

### restart into your login manager
echo
echo
echo "Excellent, now run \`shutdown -r now\`, to reboot into your desktop"
echo
echo
