#version=DEVEL
# Keyboard layouts
keyboard 'us'
# Reboot after installation
reboot
# Root password
rootpw --plaintext qweqwe
# System timezone
timezone America/New_York --isUtc --nontp
# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=link --activate
cmdline

# System bootloader configuration
bootloader --location=none
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part / --fstype="ext4" --size=3000

%post --logfile /tmp/anaconda-post.log
# Set the language rpm nodocs transaction flag persistently in the
# image yum.conf and rpm macros

LANG="en_US"
echo "%_install_lang $LANG" > /etc/rpm/macros.image-language-conf

awk '(NF==0&&!done){print "override_install_langs='$LANG'\ntsflags=nodocs";done=1}{print}' \
    < /etc/yum.conf > /etc/yum.conf.new
mv /etc/yum.conf.new /etc/yum.conf

echo "Import RPM GPG key"
releasever=$(rpm -q --qf '%{version}\n' fedora-release)
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch

rm -f /usr/lib/locale/locale-archive
rm -rf /var/cache/yum/*
rm -f /tmp/ks-script*

%end

%packages --excludedocs --nocore --instLangs=en
bash
fedora-release
vim-minimal
yum
-kernel

%end
url --url=http://compose-x86-02.phx2.fedoraproject.org/compose/21_RC5/21/Cloud/$basearch/os/
