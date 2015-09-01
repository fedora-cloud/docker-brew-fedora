#version=DEVEL
# Keyboard layouts
keyboard 'us'
# Reboot after installation
reboot
# Root password
rootpw --iscrypted --lock locked
# System timezone
timezone Etc/UTC --isUtc --nontp
# Use network installation
url --url="http://kojipkgs.fedoraproject.org/mash/rawhide-20150901/rawhide/x86_64/os/"
user --name=none
# Network information
network  --bootproto=dhcp --device=link --activate
repo --name="koji-override-0" --baseurl=http://kojipkgs.fedoraproject.org/mash/rawhide-20150901/rawhide/x86_64/os/
cmdline

# System bootloader configuration
bootloader --disabled
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part / --fstype="ext4" --size=3000

%post --logfile /tmp/anaconda-post.log
# Set the language rpm nodocs transaction flag persistently in the
# image yum.conf and rpm macros

# remove the user anaconda forces us to make
userdel -r none

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

#Setup locale properly
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

rm -rf /var/cache/yum/*
rm -f /tmp/ks-script*

#Make it easier for systemd to run in Docker container
cp /usr/lib/systemd/system/dbus.service /etc/systemd/system/
sed -i 's/OOMScoreAdjust=-900//' /etc/systemd/system/dbus.service

#Mask mount units and getty service so that we don't get login prompt
systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service

rm -f /etc/machine-id

%end

%packages --excludedocs --nocore --instLangs=en
bash
dnf
dnf-yum
fedora-release
rootfiles
vim-minimal
-kernel

%end
