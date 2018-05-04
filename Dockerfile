FROM scratch
MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV container=oci
ADD fedora-rawhide-20150901.tar.xz /

# Add default image command
CMD ["/bin/bash"]
