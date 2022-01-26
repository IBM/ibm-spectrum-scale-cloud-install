#!/usr/bin/bash

nvme_dev_map=("/dev/xvdf" "/dev/xvdg" "/dev/xvdh" "/dev/xvdi" "/dev/xvdj" "/dev/xvdk" "/dev/xvdl" "/dev/xvdm" "/dev/xvdn" "/dev/xvdo" "/dev/xvdp" "/dev/xvdq" "/dev/xvdr" "/dev/xvds" "/dev/xvdt")
nvme_vol_names=$(find /dev | grep -i 'nvme[1-9]n1$')
idx=0
rm -rf /etc/udev/rules.d/99_custom_ebs.rules
echo "# Generated by spectrum scale deployment." >> /etc/udev/rules.d/99_custom_ebs.rules
for nvme_vol in $${nvme_vol_names[@]}
do
    ln -s "$${nvme_vol}" "$${nvme_dev_map[$idx]}"
    IFS='/' read -a nvme_vol_arr <<< "$nvme_vol"
    for i in "$${nvme_vol_arr[@]}"
    do
        if [ "$i" != "dev" ]; then
            kernel_dev=$i
        fi
    done
    IFS='/' read -a nvme_dev_arr <<< "$${nvme_dev_map[$idx]}"
    for i in "$${nvme_dev_arr[@]}"
    do
        if [ "$i" != "dev" ]; then
            sym_dev="$i"
        fi
    done
    echo "KERNEL==\""$${kernel_dev}"\", SYMLINK+=\""$${sym_dev}"\"" >> /etc/udev/rules.d/99_custom_ebs.rules
    ((idx=idx+1))
done