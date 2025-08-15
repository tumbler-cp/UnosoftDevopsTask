cloud-localds \
-v --network-config=user-data network-config-B.iso user-data meta-data

sudo mv network-config-B.iso /var/lib/libvirt/images/

sudo qemu-img create -f qcow2 \
 -b /var/lib/libvirt/images/ubuntu-24.04-server-cloudimg-amd64.img -F qcow2 \
 /var/lib/libvirt/images/ubuntuB.qcow2 10G

sudo virt-install  \
 --name ubuntuB \
 --memory 4096 \
 --vcpus 2 \
 --disk /var/lib/libvirt/images/ubuntuB.qcow2,device=disk,bus=virtio \
 --disk path=/var/lib/libvirt/images/network-config-B.iso,device=cdrom \
 --os-variant ubuntu24.04 \
 --virt-type kvm \
 --graphics none \
 --network network=default,model=virtio \
 --import