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

To update the Docker Base image you can use the [Update Images workflow](https://github.com/fedora-cloud/docker-brew-fedora/actions?query=workflow%3A%22Update+Images%22).

When manually running the workflow you have to provide the release number (eg 32) and the date of the update (YYYY-MM-DD).

The GitHub action is using [fedora-container-release](https://github.com/fedora-cloud/fedora-container-release) cli to fetch images from Fedora's koji.

Each workflow will push the images to the matching release branch (eg [branch 32](https://github.com/fedora-cloud/docker-brew-fedora/tree/32))

Then record commit logs of the updates [here](https://github.com/fedora-cloud/official-images/blob/master/library/fedora)

And send a [Pull Request](https://help.github.com/articles/using-pull-requests/) from [fedora-cloud/official-images](https://github.com/fedora-cloud/official-images)
to [docker-library/official-images](https://github.com/docker-library/official-images/)
