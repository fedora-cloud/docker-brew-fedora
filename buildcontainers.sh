#!/bin/bash -x
sudo appliance-creator -c container-$1-$2.ks -d -v -t /tmp \
    -o /tmp --name "fedora-$2-$1" --release $2 \
    --format=qcow2
virt-tar-out -a \
    /tmp/fedora-$2-$1/fedora-$2-$1-sda.qcow2 / - | \
    gzip --best > fedora-$2-$1.tar.gz
