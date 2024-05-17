#!/bin/bash -x

function check_ret () {
   ret=$1
   if [ $ret -ne 0 ]; then
       echo "install_packages failure: $2"
       exit $ret
   fi
}

rawdisk=${IMAGE_PATH}/${IMAGE_NAME}
MB=$((1024*1024))
size=$(qemu-img info -f raw --output json "$rawdisk" | awk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')
rounded_size=$((($size/$MB + 1)*$MB))

echo "Rounded Size = $rounded_size"
qemu-img resize $rawdisk $rounded_size
check_ret $? "could not resize disk image with qemu-img resize"

qemu-img convert -f raw -o subformat=fixed,force_size -O vpc ${IMAGE_PATH}/${IMAGE_NAME} ${IMAGE_PATH}/es-rocky8-base-64-${DATESTAMP}
check_ret $? "could not convert disk image to vhd with qemu-img convert"
