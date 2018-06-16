#!/bin/sh
set -x
set -e

# Set temp environment vars
# export GOPATH=/tmp/go
# export PATH=${PATH}:${GOPATH}/bin
# export BUILDPATH=${GOPATH}/src/github.com/sniperkit/swagger-aor-generator
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

# Install build deps
apk --no-cache --no-progress --virtual build-deps add go gcc musl-dev make cmake openssl-dev libssh2-dev
