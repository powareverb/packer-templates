#!/bin/bash
set -e -x

check_version() {
    if [ -z "$VERSION" ]; then
        echo "RANCHEROS_VERSION must be set"
        exit 1
    fi
}

PACKER_BUILDER_TYPE=${PACKER_BUILDER_TYPE:?"PACKER_BUILDER_TYPE is not set"}

echo "type: $PACKER_BUILDER_TYPE"
echo "name: $PACKER_BUILD_NAME"
env
echo "----------------------------------------"

case $PACKER_BUILD_NAME in

    "amazon-rancher")
        echo "building amazon-rancher"
        cat >cloud-config.yml<<EOF
#cloud-config
rancher:
  resize_device: /dev/xvda
  services_include:
    rancher-server: true
  docker:
    engine: docker-1.12.6
EOF
        check_version
        sudo system-docker run --volumes-from=user-volumes --net=host --privileged rancher/os:${VERSION} -d /dev/xvda -t amazon-ebs-hvm -c $(pwd)/cloud-config.yml --no-reboot --debug -p /dev/xvda1 --append "rancher.cloud_init.datasources=[\"ec2\"]"
        exit 0
        ;;

esac

case ${PACKER_BUILDER_TYPE} in

    "virtualbox-iso")
        cat >vagrant.yml<<EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
        sudo ros install -d /dev/sda -f -c ./vagrant.yml --no-reboot
        ;;

        echo "Unknown type" 1>&2
        exit 1
        ;;
esac
