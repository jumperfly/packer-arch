#!/usr/bin/env bash

set -e

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input-qcow2> <output-ovf>" 1>&2
  exit 1
fi

QCOW2_IMAGE=$1
OVF_IMAGE=$2

VM_NAME="packer-$(date +%s)"
IMG_DIR=$(dirname $QCOW2_IMAGE)
VMDK_IMAGE=$IMG_DIR/$VM_NAME.vmdk

echo "#####"
echo "# Converting qcow2 image $QCOW2_IMAGE to vmdk image $VMDK_IMAGE"
echo "#####"
qemu-img convert -f qcow2 -O vmdk $QCOW2_IMAGE $VMDK_IMAGE
echo ""

echo "#####"
echo "# Creating vm $VM_NAME"
echo "#####"
vboxmanage createvm --name $VM_NAME --ostype ArchLinux_64 --register
echo ""

echo "#####"
echo "# Updating vm $VM_NAME"
echo "#####"
vboxmanage modifyvm $VM_NAME \
  --memory=512 \
  --boot1=disk --boot2=none --boot3=none --boot4=none \
  --usb=off --usbehci=off \
  --audio-enabled=off --audioout=off --audio-driver=null \
  --graphicscontroller=vmsvga \
  --rtcuseutc=off
echo ""

echo "#####"
echo "# Creating IDE storage controller for vm $VM_NAME"
echo "#####"
vboxmanage storagectl $VM_NAME --add=ide --name=IDE --controller=PIIX4
echo ""

echo "#####"
echo "# Attaching disk $VMDK_IMAGE to vm $VM_NAME"
echo "#####"
vboxmanage storageattach $VM_NAME --storagectl=IDE --type=hdd --device=0 --port=0 --medium=$VMDK_IMAGE
echo ""

echo "#####"
echo "# Exporting vm $VM_NAME to $OVF_IMAGE"
echo "#####"
vboxmanage export $VM_NAME --output=$OVF_IMAGE
echo ""

echo "#####"
echo "# Deleting vm $VM_NAME"
echo "#####"
vboxmanage unregistervm $VM_NAME --delete
echo ""
