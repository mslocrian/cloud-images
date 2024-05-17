#!/bin/bash -x

rawdisk=${IMAGE_PATH}/${IMAGE_NAME}
MB=$((1024*1024))
size=$(qemu-img info -f raw --output json "$rawdisk" | awk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')
rounded_size=$((($size/$MB + 1)*$MB))
echo "Rounded Size = $rounded_size"
qemu-img resize $rawdisk $rounded_size
