#!/bin/bash
#
# Prep a docker-brew-fedora[0] branch
#
#
# Docs in the f_help function
#
# [0] - https://github.com/fedora-cloud/docker-brew-fedora

f_ctrl_c() {
    printf "\n*** Exiting ***\n"
    exit $?
}
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

f_help() {
    cat <<EOF

NAME
    ${0}

SYNOPSIS
    ${0} FEDORA_RELEASE

DESCRIPTION
    This is a script that removes the requirement to download and pre-stage all
    this stuff by hand

EXAMPLE
    ${0} 26

EOF
}

f_clean_docker_images ()
{
    for i in $(sudo docker images -f 'dangling=true' -q);
    do
        sudo docker rmi $i;
    done
}

# This is the release of Fedora that is currently stable, it will define if we
# need to move the fedora:latest tag
current_stable="26"

# Define what is rawhide so we know to push that tag
current_rawhide="28"

# Sanity checking
# FIXME - Have to update this regex every time we drop a new Fedora Release
if ! [[ "${1}" =~ [24|25|26|27|28] ]];
then
    printf "ERROR: FEDORA_RELEASE missing or invalid\n"
    f_help
    exit 1
fi

# We need to query koji to find out what the latest successful builds are
build_name=$(koji -q latest-build --type=image f${1}-updates-candidate Fedora-Docker-Base | awk '{print $1}')
minimal_build_name=$(koji -q latest-build --type=image f${1}-updates-candidate Fedora-Container-Minimal-Base | awk '{print $1}')

# Download the image
temp_dir=$(mktemp -d)
workspace_dir="${temp_dir}/workspace"
pushd ${temp_dir} &> /dev/null
    # setup working dir structure
    # Need a dir for each arch, add more if/when needed
    mkdir -p ${workspace_dir}/{x86_64,armhfp,aarch64,ppc64le}

    # Download the latest builds from koji
    koji download-build --type=image ${build_name}

    # Extract the layer.tar (root filesystem) from each image and place it in
    # the architecture specific subdir. Then lay down the dockerfile.
    for image in *.tar.xz
    do
        intermediate_dir=$(tar --list -f ./${image} | head -1)
        compose_id=$(printf ${image} | awk -F. '{print $1}' | awk -F\- '{print $5}')
        arch=$(printf ${image} | awk -F. '{print $3}')

        result_tar="fedora-${1}-${arch}-${compose_id}.tar"
        result_tar_path="${workspace_dir}/${arch}/${result_tar}"

        # Extract the image so we can pull the rootfs out
        tar -xvJf ${image}
        mv ${intermediate_dir}/layer.tar ${result_tar_path}
        xz --best ${result_tar_path}

        cat > ${workspace_dir}/${arch}/Dockerfile <<EOF
FROM scratch
MAINTAINER \\
[Adam Miller <maxamillion@fedoraproject.org>] \\
[Patrick Uiterwijk <patrick@puiterwijk.org>]
ENV DISTTAG=f${1}container FGC=f${1} FBR=f${1}
ADD ${result_tar}.xz /
EOF

    done

popd &> /dev/null

printf "COMPLETED\n=> Working dir: ${workspace_dir}\n"
printf "=> Temp dir: ${temp_dir}\n=> Update: ${compose_id}\n"

