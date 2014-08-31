#!/bin/bash

set -e

if [ -e image ]
then
    echo "image/ folder already exists. Aborting."
    exit 1
fi

# Copy the base image
echo -n "Copying base image..."
mkdir image
cp base-images/trusty/image/base-trusty.qcow2 image/eauchat-develop.qcow2
echo " OK"

# Validate packer definition
echo "Validating packer.json"
packer validate packer.json

# Start the VM
echo -n "Starting VM..."
qemu-system-x86_64 \
    -m 1024M \
    -drive file=image/eauchat-develop.qcow2,if=virtio \
    -name base-trusty \
    -redir tcp:2224::22 \
    -vnc 0.0.0.0:47 \
    -machine type=pc-1.0,accel=kvm \
    -display sdl \
    -netdev user,id=user.0 \
    -device virtio-net,netdev=user.0 &
echo " OK"

# Provision the image
echo "Starting packer build"
packer build packer.json
