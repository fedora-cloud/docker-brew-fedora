FROM scratch
MAINTAINER Lokesh Mandvekar <lsm5@fedoraproject.org>
ADD Fedora-Docker-Base-20150210-rawhide.x86_64.tar.xz /

VOLUME ["/run", "/tmp"]
ENV container=docker

CMD ["/usr/bin/bash"]
