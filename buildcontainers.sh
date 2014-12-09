#!/bin/bash -x
sudo rm -rf /tmp/fedora*
rm -rf *.tar.xz
export LIBGUESTFS_BACKEND=direct
sudo appliance-creator -c container-rawhide-medium.ks -d -v -t /tmp \
    -o /tmp --name "fedora-rawhide-medium" --release rawhide \
    --format=qcow2
virt-tar-out -a \
    /tmp/fedora-rawhide-medium/fedora-rawhide-medium-sda.qcow2 / - | \
    xz --best > fedora-rawhide-medium.tar.xz
