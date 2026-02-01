#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Functions
libpath=$(readlink --canonicalize-missing "${toolpath}/includes")
source "${libpath}/functions.sh"

# Optional argument
engine=${1-"podman"}

# Load the Environment Variables into THIS Script
# eval "$(shdotenv --env ${toolpath}/.env || echo \"exit $?\")"

# Image Name
image_name="podman-container-supervisor"

# Mandatory Version
#image_version=$(cat ./.version | head -n1)
image_version=$(date +%Y%m%d)

# Options
opts=()

# Use --no-cache when e.g. updating docker-entrypoint.sh and images don't get updated as they should
#opts+=("--no-cache")

# Podman 5.x with Pasta doesn't always handle Networking Correctly
# Force to use slirp4netns
# opts+=("--network=slirp4netns")

# Pass Version to the Build System
opts+=("--build-arg")
opts+=("IMAGE_VERSION=${image_version}")

# Build Files
build_files=()

# Enable Alpine based Images
build_files+=("Dockerfile.alpine.base")
build_files+=("Dockerfile.alpine.net")

# Enable Debian based Images
# build_files+=("Dockerfile.debian.base")
# build_files+=("Dockerfile.debian.net")

# Select Platform
# Not used for now
#platform="linux/amd64"
#platform="linux/arm64/v8"

# Iterate over Build Files
for build_file in "${build_files[@]}"
do
    # Check if they are set
    if [[ ! -v image_name ]] || [[ ! -v image_tag ]]
    then
       echo "Both Container Name and Tag Must be Set" !
    fi

    # Extract Image Base
    image_base=$(echo "$build_file" | awk -F"." '{print $2}')

    # Extract Image Type
    image_type=$(echo "$build_file" | awk -F"." '{print $3}')

    # Define Tags to attach to this image
    image_tags=()
    image_tags+=("${image_name}:${image_base,,}-${image_type,,}-${image_version}")
    image_tags+=("${image_name}:${image_base,,}-${image_type,,}-latest")

    # Copy requirements into the build context
    # cp <myfolder> . -r docker build . -t  project:latest

    # For each image tag
    tag_args=()
    for image_tag in "${image_tags[@]}"
    do
       # Echo
       echo "Processing Image Tag <${image_tag}> for Container Image <${image_name}>"

       # Check if Image with the same Name already exists
       # remove_image_already_present "${image_tag}" "${engine}"

       # Add Argument to tag this Image too when running Container Build Command
       tag_args+=("-t")
       tag_args+=("${image_tag}")
    done

    # Build Container Image
    ${engine} build ${opts[*]} ${tag_args[*]} -f ${build_file} .
done
