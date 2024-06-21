#!/usr/bin/env bash

set -o errexit
set -o pipefail

GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
YELLOW_COL="\\033[33;1m"
NORMAL_COL="\\033[0;39m"

REGISTRY_DOMAIN=$1
: ${REGISTRY_DOMAIN:="docker.sgwbox.com:5001"}

IMAGES="${2:-}"

skopeo_copy() {
    if skopeo copy --dest-tls-verify=false --override-arch arm64 "docker://$1" "docker://$2"; then
        echo -e "$GREEN_COL Sync $1 successful $NORMAL_COL"
        return 0
    else
        echo -e "$RED_COL Sync $1 failed $NORMAL_COL"
        return 1
    fi
}

sync_images() {
    if [ ! -s ./images.list ]; then
       echo -e "$YELLOW_COL images.list is empty! $NORMAL_COL"
        return 1
    fi
    IFS=$'\n'
    CURRENT_NUM=0
    
    IMAGES="$(cat ./images.list | sed 's|^|\^|g' | tr '\n' '|' | sed 's/|$//')"
    TOTAL_NUMS=$(echo -e ${IMAGES} | tr ' ' '\n' | wc -l)
    for image in ${IMAGES}; do
        let CURRENT_NUM=${CURRENT_NUM}+1
        echo -e "$YELLOW_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} $NORMAL_COL"
        name="$(echo ${image} | cut -d ':' -f1)"
        tag="$(echo ${image} | cut -d ':' -f2)"

        skopeo_copy docker.io/${name}:${tag} ${REGISTRY_DOMAIN}/${name}:${tag}
    done
    unset IFS
}

if [ $# -eq 2 ]; then
  skopeo_copy docker.io/${IMAGES} ${REGISTRY_DOMAIN}/${IMAGES}
  return 0
fi

sync_images
