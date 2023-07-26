#!/usr/bin/env bash

DEPLOY_LOG=/var/adm/ras/mmclouddeploy.log
UDEV_RULES_FILE=/etc/udev/rules.d/98_custom_ebs.rules
NSD_DEVICE_DIR=/var/mmfs/etc
NSD_DEVICE_FILE=$${NSD_DEVICE_DIR}/nsddevices

function log() {
  log_time=$(date)
  echo "$log_time $1" >> $${DEPLOY_LOG}
}

# Initialize the udev rules files
rm -rf $UDEV_RULES_FILE
echo "# Generated by IBM Storage Scale deployment." >> $${UDEV_RULES_FILE}

# Prepare nsddevices script so Storage Scale can discover the links
# that are created
if [ ! -d "$${NSD_DEVICE_DIR}" ];
then
   mkdir -p "$${NSD_DEVICE_DIR}"
fi
echo "#!/bin/ksh" > $${NSD_DEVICE_FILE}
echo "# Generated by IBM Storage Scale deployment." >> $${NSD_DEVICE_FILE}
chmod u+x $${NSD_DEVICE_FILE}

# Get all EBS devices attached to this instance
device_output=$(find /dev | grep -i 'nvme[0-9]\+n1$')
log "Discovered device: $${device_output}"
IFS=$'\n' read -r -d '' -a array <<< "$${device_output}"

for nvme_device in $${array[@]}; do
  log "Processing device: $${nvme_device}"

  # Filter out all mounted EBS volumes
  # check if the device is mounted (i.e. root volume)
  lsblk_out=$(lsblk -J $${nvme_device})
  device_mount_list=$(echo "$${lsblk_out}" | jq '.blockdevices[].children // [] | .[].mountpoint')

  log "lsblk output: $${lsblk_out}
  log "device_mount_list: $${device_mount_list}

  device_mounted=1
  for device_mount_path in $${device_mount_list}
  do
    log "Device $${nvme_device} has mount path: $${device_mount_path}"
    if [ ! -z "$${device_mount_path}" ] | [ "$${device_mount_path}" != "null" ]
    then
      device_mounted=0
      log "Device $${nvme_device} is mounted as $${device_mount_path}"
    fi
  done

  # Add udev rules for all non mounted EBS volumes
  if [ "$${device_mounted}" -eq 1 ]
    then
      # Retrieve the originally supplied device mapping and other attributes to create udev rule
      nvme_id_ctrl=$(nvme amzn id-ctrl $${nvme_device} -o json)

      device_map_name=$(echo $${nvme_id_ctrl} | jq ".bdev")
      device_map_name_noquotes=$(echo $${device_map_name} | tr -d '"')

      device_serial_number=$(echo $${nvme_id_ctrl} | jq ".sn")
      vendor_id=$(echo $${nvme_id_ctrl} | jq ".vid")
      manufacteror_number=$(echo $${nvme_id_ctrl} | jq ".mn")

      # Add udev rules
      echo "KERNEL==\"nvme[0-9]n1\", ATTRS{serial}==$${device_serial_number}, SYMLINK+=$${device_map_name}" >> $${UDEV_RULES_FILE}

      # Add NSD device discovery entries
      echo "echo \"$${device_map_name_noquotes} generic\"" >> $${NSD_DEVICE_FILE}
      log "Device $${nvme_device} was orginally mapped as $${device_map_name} with sn: $${device_serial_number}"
  fi
done

# Finalize the NSD device discovery script
echo "# Bypass the NSD device discovery" >> $${NSD_DEVICE_FILE}
echo "return 0" >> $${NSD_DEVICE_FILE}

# Run the udev rules to generate the links
udevadm control --reload-rules && udevadm trigger
