#!/usr/bin/env bash

dev_name_map=("xvdf" "xvdg" "xvdh" "xvdi" "xvdj" "xvdk" "xvdl" "xvdm" "xvdn" "xvdo" "xvdp" "xvdq" "xvdr" "xvds" "xvdt")
nvme_vol_names=$(find /dev | grep -i 'nvme[1-9]n1$')

# Prepare nsddevices script so Storage Scale can discover the links that are created
nsd_device_dir=/var/mmfs/etc
if [ ! -d "$nsd_device_dir" ];
then
   mkdir -p "$nsd_device_dir"
fi
echo "#!/bin/ksh" > /var/mmfs/etc/nsddevices
chmod u+x /var/mmfs/etc/nsddevices

rm -rf /etc/udev/rules.d/99_custom_ebs.rules
echo "# Generated by spectrum scale deployment." >> /etc/udev/rules.d/99_custom_ebs.rules

idx=0
for nvme_vol in $${nvme_vol_names[@]}
do
    ln -s "$${nvme_vol}" "/dev/$${dev_name_map[$idx]}"
    IFS='/' read -a nvme_vol_arr <<< "$nvme_vol"
    for i in "$${nvme_vol_arr[@]}"
    do
        if [ "$i" != "dev" ]; then
            kernel_dev=$i
        fi
    done
    IFS='/' read -a nvme_dev_arr <<< "/dev/$${dev_name_map[$idx]}"
    for i in "$${nvme_dev_arr[@]}"
    do
        if [ "$i" != "dev" ]; then
            sym_dev="$i"
        fi
    done
    echo "KERNEL==\""$${kernel_dev}"\", SYMLINK+=\""$${sym_dev}"\"" >> /etc/udev/rules.d/99_custom_ebs.rules
    echo "echo $${dev_name_map[$idx]} generic" >> /var/mmfs/etc/nsddevices
    ((idx=idx+1))
done

echo "return 1" >> /var/mmfs/etc/nsddevices

