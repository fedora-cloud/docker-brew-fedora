import datetime
import os
import re
import shutil
import tarfile

import jinja2
import koji

from invoke import task

GIT_REPO = "https://github.com/fedora-cloud/docker-brew-fedora.git"
DOWNLOAD_URL = "https://kojipkgs.fedoraproject.org/"
TEMPLATE_FILE = "Dockerfile.j2"


def get_koji_archives(tag, package):
    """
    Get the list of archives to download from koji
    given a release tag and a package name.
    """
    client = koji.ClientSession("https://koji.fedoraproject.org/kojihub")
    builds = client.listTagged(tag, latest=True, package=package, type="image")

    images = client.listArchives(buildID=builds[0]["id"], type="image")

    pi = koji.PathInfo(topdir=DOWNLOAD_URL)

    urls = []
    for image in images:
        if ".tar.xz" in image["filename"]:
            urls.append(f"{pi.imagebuild(builds[0])}/{image['filename']}")
    return urls


@task
def push_containers(c, release, minimal=False, workdir="/tmp/"):

    with open(TEMPLATE_FILE) as fp:
        template = jinja2.Template(fp.read())

    package = "Fedora-Container-Base"
    if minimal:
        package = "Fedora-Container-Minimal-Base"
    urls = get_koji_archives(tag="f" + release, package=package)
    print(f"{len(urls)} archives to process")

    os.chdir(workdir)
    for url in urls:
        # For each archive prepare the container filesystem.
        image_name = url.split("/")[-1]
        m = re.search(r"-(\d+)\.", image_name)
        if m is None:
            print("compose id not found")
            continue

        compose_id = m.group(1)
        arch = image_name.split(".")[-3]

        workspace=f"workspace-{release}/"
        os.makedirs(workspace + arch)

        # Download koji's archive if not already done
        if not image_name in os.listdir(workdir):
            print(f"Download: {image_name}")
            c.run(f"curl -O {url}")

        # Extract koji's archive
        print("Extracting tar archive")
        with tarfile.open(image_name) as tar:
            hash_name = tar.getmembers()[0].name
            tar.extractall()

        # Create the results path ie workspace-31/x86_64/fedora-31-x86_64-20190331.tar
        result_tar = f"fedora-{release}-{arch}-{compose_id}.tar"
        result_path = workspace + arch + "/" + result_tar

        # We want only the rootfs (layer.tar) from the archive.
        c.run(f"mv {hash_name + '/layer.tar'} {result_path}")

        # We compress the tarball.
        c.run(f"xz --best {result_path}")

        # Add the Dockerfile
        dockerfile = template.render(tag=release, result_tar=result_tar + ".xz")
        with open(workspace + arch + "/Dockerfile", "w") as fp:
            fp.write(dockerfile)

    if not "docker-brew-fedora" in os.listdir(workdir):
        c.run(f"git clone {GIT_REPO}")

    os.chdir("docker-brew-fedora")
    current_dir = os.getcwd()

    c.run(f"git branch -D {release}", warn=True)
    c.run(f"git checkout --orphan {release}", warn=True)
    c.run(f"git rm --cached -r {current_dir}", warn=True)

    for dir in os.scandir(current_dir):
        if dir.is_dir():
            if "." not in dir.name:
                shutil.rmtree(dir.path)
        else:
            os.remove(dir.path)

    for dir in os.scandir(workdir + workspace):
        shutil.move(dir.path, current_dir)

    c.run(f"rm -rf {workdir + workspace}", warn=True)
    c.run("git add .", warn=True)
    c.run(f"git commit -m 'Update fedora {release} - {datetime.date.today()}'", warn=True)
    c.run(f"git push -f origin {release}", warn=True)
    c.run(f"git checkout master", warn=True)
