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

1. Run the `./prep-docker-brew-branch.sh` script, this will create a "stage"
   directory. This requires the `koji` and `tar` packages to be installed on the
   machine where you run this.

   At the end of the script you will see something similar to:

```
COMPLETED
=> Working dir: /tmp/tmp.Jckt4DUhIM/workspace
=> Temp dir: /tmp/tmp.Jckt4DUhIM
=> Update: 20170912
```

2. Make sure that the result of the previous is correct, it should look like the
   following:

```
$ tree /tmp/tmp.Jckt4DUhIM/workspace
/tmp/tmp.Jckt4DUhIM/workspace
├── aarch64
│   ├── Dockerfile
│   └── fedora-26-aarch64-20170912.tar.xz
├── armhfp
│   ├── Dockerfile
│   └── fedora-26-armhfp-20170912.tar.xz
├── ppc64le
│   ├── Dockerfile
│   └── fedora-26-ppc64le-20170912.tar.xz
└── x86_64
    ├── Dockerfile
        └── fedora-26-x86_64-20170912.tar.xz

        4 directories, 8 files
```

2. Force push to fedora-cloud/docker-brew-fedora on github in order to overwrite
   history so we aren’t storing giant piles of tarballs in git.

```
# EXAMPLE

# The value of work_dir comes from the previous output of the
# ./prep-docker-brew-branch.sh script in Step 1
$ work_dir=/tmp/tmp.Jckt4DUhIM/workspace

$ git checkout master

$ git branch -D 26

$ git checkout --orphan 26

$ git rm --cached -r .

$ rm -fr ./*

## Move in the files from your working dir

$ mv ${work_dir}/{x86_64,armhfp,aarch64,ppc64le} .

$ git add .

$ gc -m "Update to fedora 26 - 20170912"
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

3. Record commit logs of the updates
   [here](https://github.com/fedora-cloud/official-images/blob/master/library/fedora)

4. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [fedora-cloud/official-images](https://github.com/fedora-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
