FROM scratch
MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV DISTTAG=f26docker FGC=f26 FBR=f26
ADD fedora-26-20170620.tar.xz /
