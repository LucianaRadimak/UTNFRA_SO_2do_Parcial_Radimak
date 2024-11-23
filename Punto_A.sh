#!/bin/bash

sudo fdisk -l

DISCO1GB="/dev/sdc"

# Partición del disco de 1GB:
sudo fdisk "$DISCO1GB" <<EOF
n
p
1

+5M
t
8e
w
EOF

#Ahora la convierto a volumen fisico y creo el grupo de volumenes "vg_datos"
sudo pvcreate "${DISCO1GB}1"
sudo vgcreate vg_datos "${DISCO1GB}1"

DISCO2GB="/dev/sdd"

# Hago la partición del disco de 2GB
sudo fdisk "$DISCO2GB" <<EOF
n
p
1

+1.5G
t
8e
w
EOF

# Convierto la particion del disco de 2GB a volumen fisico y extiendo el grupo de volumenes "vg_datos"
sudo pvcreate "${DISCO2GB}1"
sudo vgextend vg_datos "${DISCO2GB}1"

# Segunda particion del disco de 2GB
sudo fdisk "$DISCO2GB" <<EOF
n
p
2


t
2
8e
w
EOF

# Convierto la segunda particion del disco de 2GB a volumen fisico y creo el grupo de volumenes "vg_temp"
sudo pvcreate "${DISCO2GB}2"
sudo vgcreate vg_temp "${DISCO2GB}2"

# Para comprobar que los grupos de volumenes se hayan asignado bien...
sudo vgs

# Ahora creo los volumenes lógicos... 

# El lv "lv_docker" de 5MB
sudo lvcreate -L 5M vg_datos -n lv_docker

# El lv "lv_workareas" de 1.5G
<<<<<<< HEAD
sudo lvcreate -L 100%FREE vg_datos -n lv_workareas

# El lv "lv_swap" de 512MB
sudo lvcreate -L 100%FREE vg_temp -n lv_swap
=======
sudo lvcreate -L 1.5G vg_datos -n lv_workareas

# El lv "lv_swap" de 512MB
sudo lvcreate -L 512m vg_temp -n lv_swap
>>>>>>> 55adb91 (Update: Punto A)

sudo lvs
sudo fdisk -l

sudo mkfs -t ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs -t ext4 /dev/mapper/vg_datos-lv_workareas
sudo mkswap /dev/mapper/vg_temp-lv_swap

sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_workareas /work/
df -h
sudo swapon /dev/vg_temp/lv_swap
free -h
