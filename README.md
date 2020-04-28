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
[bug](https://bugzilla.redhat.com/enter_bug.cgi?product=Fedora Container Images&component=fedora-container-image).

Docker Base Image Import process
--------------------------------
1. Install the dependencies in a virtual environment
```
   $ python -m venv .venv
   $ source .venv/bin/activate
   (.venv) $ pip install -r requirements.txt

2. Run the tasks using the invoke command.
```
    (.venv) $ invoke --list
    Available tasks:

      push-containers
```

To push the Fedora 31 container we can run the following command

```
    (.venv) $ invoke push-containers 31
```

This will push format and push the Dockerfile and rootfs tarball on the 31 branch.

3. Record commit logs of the updates
   [here](https://github.com/fedora-cloud/official-images/blob/master/library/fedora)

4. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [fedora-cloud/official-images](https://github.com/fedora-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
