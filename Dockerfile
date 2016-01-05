FROM scratch
MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV container=oci
ADD fedora-rawhide-20150901.tar.xz /

# Labels added in support of osbs, per https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="Fedora Base Image" \
      vendor="Fedora" \
      license="MIT" \
      url="https://fedoraproject.org/wiki/Cloud" \
      release="<release version, or rawhide>" \
      build-date="<output of date --rfc-3339=date>"

#default CMD defined per best practices at https://github.com/docker-library/official-images/blob/master/README.md
CMD ["/bin/bash"]
