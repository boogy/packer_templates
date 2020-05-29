#!/bin/bash -eux

## add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/Defaults !requiretty/" /etc/sudoers

## disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

## put some color in the prompt
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc

## setup the keyboard permanently
cat <<EOF > /etc/default/keyboard
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="ch"
XKBVARIANT="fr"
XKBOPTIONS="lv3:ralt_switch"

BACKSPACE="guess"
EOF

## make sure virtualbox driver is loded
echo vboxsf >> /etc/modules

export DEBIAN_FRONTEND=noninteractive
## install packages
# dpkg --add-architecture i386
# japt update
# apt -yq install libc6:i386 libc6-dev-i386 libncurses5:i386 libstdc++6:i386

apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get -yq install linux-headers-$(uname -r) software-properties-common apt-transport-https build-essential git curl wget \
    python2.7 python-pip python-dev python3-dev python3-pip python3-cryptography python-openssl python-virtualenv virtualenvwrapper python-scapy \
    python3-scapy make cmake stunnel socat hydra p7zip rar unrar unzip strace ltrace bzip2 gzip rdesktop libssl-dev libffi-dev \
    whois samba-common samba-common-bin yasm nasm sslsplit gdb gdb-multiarch tmux vim nfs-common dkms \
    gdbserver gcc gcc-multilib gcc-mingw-w64 python3-scapy python3-requests python-requests

## clean apt
apt-get install -f
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/cache/* /usr/share/doc/*

python2 -m pip install --upgrade pip
python2 -m pip install --upgrade pwntools

## vagrant user commands
sudo -H -u vagrant bash <<EOF
mkdir -p /home/vagrant/tools && cd /home/vagrant/tools
git clone https://github.com/pwndbg/pwndbg.git
cd pwndbg && ./setup.sh
EOF

## installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

## install Virtualbox tools
mkdir /tmp/isomount
mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount

## install the drivers
/tmp/isomount/VBoxLinuxAdditions.run
umount /tmp/isomount
usermod -a -G vboxsf vagrant

# Cleanup
FILES_TO_DELETE=(
    "/home/vagrant/VBoxGuestAdditions.iso"
    "/home/vagrant/.sudo_as_admin_successful"
    "/home/vagrant/.wget-hsts"
    "/home/vagrant/.sudo_as_admin_successful"
    "/home/vagrant/.vbox_version"
    "/home/vagrant/.bash_history"
    "/home/vagrant/.cache"
    "/home/vagrant/*.sh"
)
for F in ${FILES_TO_DELETE[@]}; do
    rm -rf $F
done

## clean up unused disk space so compressed image is smaller.
cat /dev/zero > /tmp/zero.fill
rm /tmp/zero.fill