#!/usr/bin/env bash

# Convert a .qcow2 file into a .wim image.

set -euox pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: qcow2-to-wim.sh SOURCE SOURCE_PARTITION DEST"
  exit 1
fi

SOURCE="$1"
SOURCE_PARTITION="$2"
DEST="$3"

sudo modprobe nbd max_part=8
sudo qemu-nbd --read-only --connect=/dev/nbd0 "$SOURCE"
trap "sudo qemu-nbd --disconnect /dev/nbd0" EXIT

# Wait for the device files to appear
sleep 1

sudo wimcapture "/dev/nbd0p$SOURCE_PARTITION" "$DEST" --compress=LZX
