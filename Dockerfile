FROM scratch
MAINTAINER Lokesh Mandvekar <lsm5@fedoraproject.org>
ADD fedora-21-release.tar.xz /

#systemd fails to mount stuff in containers due to missing sysadmin cap
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service

#dbus.service fails to run due to missing caps for setting OOMScore
RUN cp /usr/lib/systemd/system/dbus.service /etc/systemd/system/; sed -i 's/OOMScoreAdjust=-900//' /etc/systemd/system/dbus.service

#systemd expects /run and /tmp to be mount points
VOLUME ["/run", "/tmp"]

#systemd expects env variable $container to define the virt type
ENV container=docker

CMD ["/usr/bin/bash"]
