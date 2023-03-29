## 扩容

```
reboot
fdisk -l
fdisk /dev/sda
partprobe
pvcreate /dev/sda3
vgextend cl /dev/sda3 
lvextend -l +100%FREE /dev/mapper/cl-root
xfs_growfs /dev/mapper/cl-root
df -h
```