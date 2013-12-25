#!/bin/bash -x
sudo rm -rf /tmp/fedora*
rm *.tar.xz
sudo appliance-creator -c container-20-medium.ks -d -v -t /tmp \
    -o /tmp --name "fedora-20-medium" --release 20 \
    --format=qcow2
virt-tar-out -a \
    /tmp/fedora-20-medium/fedora-20-medium-sda.qcow2 / - | \
    xz --best > fedora-20-medium.tar.xz
