docker-brew-fedora
==================

This project space exists as an upload entry point to import the official
[Fedora](https://getfedora.org/) [Docker](https://www.docker.com/)
Base Images built in [Fedora Koji](http://koji.fedoraproject.org/koji/)
(Fedora's Build System) so that they may be submitted to the
[official-images](https://github.com/docker-library/official-images) repository
for the [Docker Hub](https://hub.docker.com/).

These images are built from a [kickstart](https://github.com/rhinstaller/pykickstart/blob/master/docs/kickstart-docs.rst)
file that is part of the [Fedora
kickstarts](https://pagure.io/fedora-kickstarts) sub-project of Fedora. If there
is an issue or request for a change to the contents of the Fedora Docker Base
Image, please file an
[bug](https://bugzilla.redhat.com/enter_bug.cgi?product=Fedora&component=spin-kickstarts).

Docker Base Image Import process
--------------------------------

1. Setup a workspace tempdir, this can really be anywhere on your filesystem but
   I'm going to say `/tmp/` for the purpose of the example.

   Make a subdirectory for each container image type we support (Currently that
   is `x86_64`, `armhfp`, `aarch64`, and `ppc64le`).

```
$ mkdir -p /tmp/fedora-26-docker/{x86_64,armhfp,aarch64,ppc64le}

$ cd /tmp/fedora-26-docker

```

2. Extract the rootfs from the koji tarballs that
   [Fedora Release-Engineering](https://fedoraproject.org/wiki/ReleaseEngineering)
   provides.
   * Nightly builds of [rawhide](https://fedoraproject.org/wiki/Releases/Rawhide)
   and
   [branched](https://fedoraproject.org/wiki/Releases/Branched)
   are located
   [here](http://koji.fedoraproject.org/koji/tasks?start=0&state=all&view=tree&method=image&order=-id).

   You will need to pull an image for each architecture we support (currently
   that is ``x86_64``, ``armhfp``, ``aarch64``, and ``ppc64le``). You will need
   to follow the below process for each architecture also.

```
# EXAMPLE:

$ tar -xvJf Fedora-Docker-Base-26-1.5.x86_64.tar.xz
075f42bd7f5192efdb25ebe5d0c9ea0f2a67f0bb9c0cae64ab85360657d25ba7/
075f42bd7f5192efdb25ebe5d0c9ea0f2a67f0bb9c0cae64ab85360657d25ba7/layer.tar
075f42bd7f5192efdb25ebe5d0c9ea0f2a67f0bb9c0cae64ab85360657d25ba7/VERSION
075f42bd7f5192efdb25ebe5d0c9ea0f2a67f0bb9c0cae64ab85360657d25ba7/json
repositories
7c100629c0cb12a60446f5b67e18d049d22794fc34fbf76c523290d0e8858bef.json
manifest.json
```

3. Re-name the `layer.tar` to something meaningful, example
   `fedora-${release}-${arch}-${compose_date}`. This is needed because Docker
   Hub only takes tarballs of the rootfs while the koji tarball has the rootfs
   along with metadata.

   NOTE: `$compose_date` is found on the koji web page you downloaded the image
   from.

```
# EXAMPLE:

$ mv layer.tar x86_64/fedora-26-x86_64-20170705.tar

$ xz --best x86_64/fedora-26-x86_64-20170705.tar
```

4. Copy the `Dockerfile` from the corresponding branch of this repo into our
   workspace and update it. In this example we're using the `26` branch to
   correspond to the Fedora 26 release.

```

$ git checkout 26

$ cp x86_64/Dockerfile /tmp/fedora-26-docker/x86_64/

```

Now update the `ADD` statement in the Dockerfile.

Example:

```
FROM scratch
MAINTAINER \
[Adam Miller <maxamillion@fedoraproject.org>] \
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV DISTTAG=f26docker FGC=f26 FBR=f26
ADD fedora-26-x86_64-20170705.tar.xz /
```

### REPEAT THIS PROCESS FOR EACH ARCHITECTURE BEFORE MOVING ON TO STEP 5

5. Force push to fedora-cloud/docker-brew-fedora on github in order to overwrite
   history so we aren’t storing giant piles of tarballs in git.

```
# EXAMPLE

$ git checkout master

$ git branch -D 26

$ git checkout --orphan 26

$ git rm --cached -r .

$ rm -fr ./*

## Move in the files from your working dir

$ mv /tmp/fedora-26-docker/{x86_64,armhfp,aarch64,ppc64le} .

$ git add .

$ gc -m "add multi-arch for fedora 26"
[26 (root-commit) c726745] add multi-arch for fedora 26
 8 files changed, 24 insertions(+)
 create mode 100644 aarch64/Dockerfile
 create mode 100644 aarch64/fedora-26-aarch64-20170705.tar.xz
 create mode 100644 armhfp/Dockerfile
 create mode 100644 armhfp/fedora-26-armhfp-20170705.tar.xz
 create mode 100644 ppc64le/Dockerfile
 create mode 100644 ppc64le/fedora-26-ppc64le-20170705.tar.xz
 create mode 100644 x86_64/Dockerfile
 create mode 100644 x86_64/fedora-26-x86_64-20170705.tar.xz


$ git push -f origin 26
```

5. Record commit logs of the updates
   [here](https://github.com/fedora-cloud/official-images/blob/master/library/fedora)

6. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [fedora-cloud/official-images](https://github.com/fedora-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
