#!/bin/bash -x

export PACKER_LOG=1
source venv/bin/activate

#packer init -upgrade .

packer build -only=qemu.rockylinux-8-azure-x86_64 .


