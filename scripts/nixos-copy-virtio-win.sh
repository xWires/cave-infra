#!/usr/bin/env bash

# The `virtio-win` package on NixOS is unwritable because it is located in /nix/store.
# This script will make a copy of the necessary files from the package and place them in images/windows_server/drivers/

set -euox pipefail

cd "$(dirname "$0")"

VIRTIO=$(nix-build '<nixpkgs>' -A virtio-win --no-out-link)

rm -rf ../images/windows_server/drivers
mkdir -p ../images/windows_server/drivers/vioscsi/2k22/amd64 ../images/windows_server/drivers/NetKVM/2k22/amd64

cp -r --no-preserve=mode "$VIRTIO/vioscsi/2k22/amd64" ../images/windows_server/drivers/vioscsi/2k22/
cp -r --no-preserve=mode "$VIRTIO/NetKVM/2k22/amd64" ../images/windows_server/drivers/NetKVM/2k22/

chmod -R u+w ../images/windows_server/drivers/vioscsi/2k22/
