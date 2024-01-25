#!/usr/bin/env sh
set -e

confirm() {
    value="n"
    while [ ! "$value" = "y" ]; do
        printf "confirm [y/n]:"
        read value
        if [ "$value" = "n" ]; then
            1>&2 echo "user aborted operation"
            exit 1
        fi
    done
}

PUSH="${PUSH:-0}"

repo="docker.io"
image="benfiola/palworld"
version="0.1.3.0-2"

echo "building image"
docker build -t "${repo}/${image}:${version}" -t "${image}:${version}" -t "${image}:latest" .

if [ "$PUSH" = "1" ]; then
    echo "pushing image"
    echo "tag: ${repo}/${image}:${version}"
    confirm
    docker push "${repo}/${image}:${version}"
fi
