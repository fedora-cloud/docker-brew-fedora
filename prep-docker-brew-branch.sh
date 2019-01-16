#!/bin/bash -xe
#
# Prep a docker-brew-fedora[0] branch
#
#
# Docs in the f_help function
#
# [0] - https://github.com/fedora-cloud/docker-brew-fedora

# use all CPU cores when compressing unless XZ_DEFAULTS is already defined
export XZ_DEFAULTS="${XZ_DEFAULTS:--T 0}"

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

uuidgen >/dev/null

f_clean_docker_images ()
{
    for i in $(sudo docker images -f 'dangling=true' -q);
    do
        sudo docker rmi $i;
    done
}

# Sanity checking
# FIXME - Have to update this regex every time we drop a new Fedora Release
if ! [[ "${1}" =~ [24|25|26|27|28|29|30] ]];
then
    printf "ERROR: FEDORA_RELEASE missing or invalid\n"
    f_help
    exit 1
fi

# FIXME - Have to update the 29 everytime
if [[ "${1}" == "30" ]];
then
	tag="f${1}"
else
	tag="f${1}-updates-candidate"
fi


# We need to query koji to find out what the latest successful builds are
if [[ "${1}" > 27 ]];
then
	# This was renamed for f28+
	build_name=$(koji -q latest-build --type=image $tag Fedora-Container-Base | awk '{print $1}')
else
	build_name=$(koji -q latest-build --type=image $tag Fedora-Docker-Base | awk '{print $1}')
fi
minimal_build_name=$(koji -q latest-build --type=image $tag Fedora-Container-Minimal-Base | awk '{print $1}')

# Download the image
temp_dir=$(mktemp -d)
workspace_dir="${temp_dir}/workspace"
pushd ${temp_dir} &> /dev/null

    # Download the latest builds from koji
    koji download-build --type=image ${build_name}

    # Extract the layer.tar (root filesystem) from each image and place it in
    # the architecture specific subdir. Then lay down the dockerfile.
    for image in *.tar.xz
    do
        intermediate_dir=$(tar --list -f ./${image} | head -1)
        compose_id=$(printf ${image} | awk -F. '{print $1}' | awk -F\- '{print $5}')
        arch=$(printf ${image%*.tar.xz} | awk -F. '{print $NF}')

        # setup working dir structure
        # Need a dir for each arch, add more if/when needed
        mkdir -p ${workspace_dir}/${arch}

        result_tar="fedora-${1}-${arch}-${compose_id}.tar"
        result_tar_path="${workspace_dir}/${arch}/${result_tar}"

        # Extract the image so we can pull the rootfs out
        tar -xvJf ${image}
        mv ${intermediate_dir}/layer.tar ${result_tar_path}
        xz --best ${result_tar_path}

        cat > ${workspace_dir}/${arch}/Dockerfile <<EOF
FROM scratch
LABEL maintainer="Clement Verna <cverna@fedoraproject.org>"
ENV DISTTAG=f${1}container FGC=f${1} FBR=f${1}
ADD ${result_tar}.xz /
CMD ["/bin/bash"]
EOF

    done

popd &> /dev/null

echo "Testing x86_64..."
testtag=$(uuidgen)
podman build -t ${testtag} "${workspace_dir}/x86_64"
podman run --rm --entrypoint /bin/bash ${testtag} -c "/bin/dnf install -y cowsay && cowsay Working"
podman rmi ${testtag}
echo "Seems to be working reasonableish"

printf "COMPLETED\n=> Working dir: ${workspace_dir}\n"
printf "=> Temp dir: ${temp_dir}\n=> Update: ${compose_id}\n"

