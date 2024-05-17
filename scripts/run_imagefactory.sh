#!/bin/bash

function check_ret () {
   ret=$1
   if [ $ret -ne 0 ]; then
       echo "install_packages failure: $2"
       exit $ret
   fi
}

cat << EOF > /etc/yum.repos.d/image-factory.repo
[image-factory]
name = image-factory
baseurl=https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@artifactory-uw2.adobeitc.com/artifactory/rpm-image-factory-hardener-prod-release/rocky-linux-8/generic
enabled=1
gpgcheck=1
gpgkey=https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@artifactory-uw2.adobeitc.com/artifactory/rpm-image-factory-hardener-prod-release/IF_Hardener_Pub
EOF

dnf makecache

dnf -y install if-hardener-rocky-linux-8

/opt/image-factory-hardener/bin/exec --run --implement-high-risk --edr-ccid=${EDR_CCID} --edr-tags=${EDR_TAGS} --golden-image
