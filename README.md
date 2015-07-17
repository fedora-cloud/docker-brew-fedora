# docker-brew-fedora

1. Extract the rootfs from the koji tarballs that fedora rel-eng provides.
2. Re-tar the rootfs into xz fomat
3. add the tarball in step 2 along with the kickstart script used to the appropriate branch in this repo.
4. Force push (or do whatever to make sure to wipeout all prior history) to fedora-cloud/docker-brew-fedora on github.

5. record commit logs of the updates in: https://github.com/fedora-cloud/official-images/blob/master/library/fedora
6. Send a PR from fedora-cloud/official-images to docker-library/official-images
