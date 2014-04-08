# This is a kickstart for making a non-bootable container environment.
#
# Convert the result to a tarfile with 
#
#   virt-tar-out -a fedora.qcow2 / - | bzip2 --best > fedora.tar.bz2
#
#
# This kickstart file is designed to be used with appliance-creator and
# may need slight modification for use with actual anaconda or other tools.
# We intend to target anaconda-in-a-vm style image building for F20, but
# not necessarily for containers -- that's yet to be worked out.

lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC

auth --useshadow --enablemd5
selinux --enforcing
rootpw --lock --iscrypted locked

zerombr
clearpart --all
part / --size 1024 --fstype ext4

# Repositories
repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-20&arch=$basearch
repo --name=fedora-updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f20&arch=$basearch

reboot

# Package list.
%packages
@core
tar
rsync

# https://bugzilla.redhat.com/show_bug.cgi?id=1004976
firewalld

# Some things from @core we can do without inside the container
-audit
-biosdevname
-dhclient
-e2fsprogs
-grubby
-iprutils
-kbd
-NetworkManager
-openssh-server
-parted
-plymouth   
-policycoreutils
-rsyslog
-selinux-policy-targeted

%end

%post --erroronfail

# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

# create devices which appliance-creator does not
ln -s /proc/kcore /dev/core
mknod -m 660 /dev/loop0 b 7 0
mknod -m 660 /dev/loop1 b 7 1
rm -rf /dev/console
ln -s /dev/tty1 /dev/console

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
EOF

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo .

# Because memory is scarce resource in most cloud/virt environments,
# and because this impedes forensics, we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount

echo "Removing random-seed so it's not the same in every image."
rm -f /var/lib/random-seed

echo "Compressing cracklib."
gzip -9 /usr/share/cracklib/pw_dict.pwd

echo "Removing extra packages."
rm -vf /etc/yum/protected.d/
yum -C -y remove firewalld --setopt="clean_requirements_on_remove=1"

echo "Cleaning old yum repodata."
yum clean all
yum history new
truncate -c -s 0 /var/log/yum.log

echo "Removing boot, since we don't need that."
rm -rf /boot/

echo "Fixing SELinux contexts."
/usr/sbin/fixfiles -R -a restore

echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
rm -f /var/tmp/zeros
echo "(Don't worry -- that out-of-space error was expected.)"

%end

