docker-brew-fedora
==================

This project space exists as an upload entry point to import the official 
[Fedora](https://getfedora.org/) [Docker](https://www.docker.com/)
Base Images built in [Fedora Koji](http://koji.fedoraproject.org/koji/)
(Fedora's Build System) so that they may be submitted to the
[official-images](https://github.com/docker-library/official-images) repository
for the [Docker Hub](https://hub.docker.com/).

These images are built from a [kickstart](https://github.com/rhinstaller/pykickstart/blob/master/docs/kickstart-docs.rst)
file that is part of the [Fedora spin-kickstarts](https://fedorahosted.org/spin-kickstarts/)
sub-project of Fedora. If there is an request for a change to the contents
of the Fedora Docker Base Image, please file an issue ticket in the Fedora
spin-kickstarts [trac](http://trac.edgewall.org/) instance
[here](https://fedorahosted.org/spin-kickstarts/newticket).

Docker Base Image Import process
--------------------------------

1. Extract the rootfs from the koji tarballs that
   [Fedora Release-Engineering](https://fedoraproject.org/wiki/ReleaseEngineering)
   provides.
   * Nightly builds of [rawhide](https://fedoraproject.org/wiki/Releases/Rawhide)
   and
   [branched](https://fedoraproject.org/wiki/Releases/Branched)
   are located
   [here](http://koji.fedoraproject.org/koji/tasks?start=0&state=all&view=tree&method=image&order=-id).
   ```
# EXAMPLE:

$ tar -xvJf Fedora-Docker-Base-rawhide-20150716.x86_64.tar.xz
e7dac1f802a53315e8d8b719d3ff2bea8e65026674a67cf631d1ea3f5244756b/
e7dac1f802a53315e8d8b719d3ff2bea8e65026674a67cf631d1ea3f5244756b/json
e7dac1f802a53315e8d8b719d3ff2bea8e65026674a67cf631d1ea3f5244756b/VERSION
e7dac1f802a53315e8d8b719d3ff2bea8e65026674a67cf631d1ea3f5244756b/layer.tar
repositories
```

2. Re-name the `layer.tar` to something meaningful, example
   `fedora-${release}-release`. This is needed because Docker Hub only takes
   tarballs of the rootfs while the koji tarball has the rootfs along with
   metadata.
   ```
# EXAMPLE:

$ mv layer.tar fedora-rawhide-20150716.tar

$ xz --best fedora-rawhide-20150716.tar
```

3. Add the xz compressed tarball in step 2 along with the kickstart script
   used to the appropriate branch in this repo. (Update the Dockerfile if the
   tar.xz filename changed or otherwise necessary)

4. Force push to fedora-cloud/docker-brew-fedora on github in order to overwrite
   history so we aren’t storing giant piles of tarballs in git.
   ```
# EXAMPLE

$ git checkout master

$ git branch -D rawhide

$ git checkout --orphan rawhide

$ git rm --cached -r .

## Copy in the files from your working dir

$ git add .

$ git commit -m “update rawhide - 20150716”
[rawhide 4aa1a9e] update rawhide - 20150716
 Date: Mon Jul 20 15:25:00 2015 -0500
 4 files changed, 92 insertions(+)
 create mode 100644 Dockerfile
 create mode 100644 README.md
 create mode 100644 fedora-rawhide-20150716.tar.xz
 create mode 100644 koji-f24-build-10384746-base.ks

$ git push -f origin rawhide
```

5. Record commit logs of the updates
   [here](https://github.com/fedora-cloud/official-images/blob/master/library/fedora)

6. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [fedora-cloud/official-images](https://github.com/fedora-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
