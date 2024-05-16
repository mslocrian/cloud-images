#!/bin/bash -x

export PACKER_LOG=1
source venv/bin/activate
source /etc/os-release

export PKR_VAR_ARTIFACTORY_USERNAME=${ARTIFACTORY_USER}
export PKR_VAR_ARTIFACTORY_PASSWORD=${CORP_ARTIFACTORY_PASSWORD_UW2}

#packer init -upgrade .

if [[ "${ID}" == "rocky" ]]; then
    packer build -var "headless=true" -var "qemu_binary=qemu-kvm" -only=qemu.rockylinux-8-azure-x86_64 .
else
    packer build -only=qemu.rockylinux-8-azure-x86_64 .
fi


