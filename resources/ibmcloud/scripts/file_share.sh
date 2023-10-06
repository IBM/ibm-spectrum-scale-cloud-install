#!/bin/bash


yum install -y nfs-utils
# yum -y install openldap-clients nss-pam-ldapd
# yum install authselect sssd oddjob oddjob-mkhomedir -y

echo "$client_nodes"
echo "$protocol_instance_names"

IFS=' ' read -ra client_node <<< "$client_nodes"
IFS=' ' read -ra protocol_instance_name <<< "$protocol_instance_names"

current_client_node=$(hostname)

client_node_index=-1
for ((i=0; i<${#client_node[@]}; i++)); do
  if [ "${client_node[i]}" = "$current_client_node" ]; then
    client_node_index=$i
    break
  fi
done

if [ $client_node_index -eq -1 ]; then
  echo "Error: Client node not found in the list."
  exit 1
fi

protocol_node_index=$((client_node_index % ${#protocol_instance_name[@]}))
protocol_node="${protocol_instance_name[$protocol_node_index]}"

echo "Client Node: $current_client_node"
echo "Protocol Node: $protocol_node"

echo "$custom_file_shares"
echo "$list_of_filesets"

IFS=' ' read -ra custom_file_share <<< "$custom_file_shares"
IFS=' ' read -ra list_of_fileset <<< "$list_of_filesets"

if [ -n "${custom_file_share}" ]; then
  echo "Custom file share ${custom_file_share[@]} found"

  file_share_array=("${custom_file_share[@]}")
  fileset_array=("${list_of_fileset[@]}")

  echo "file_share_array: ${file_share_array[@]}"
  echo "fileset_array: ${fileset_array[@]}"

  length=${#file_share_array[@]}
  echo "Length: $length"

  for (( i=0; i<length; i++ ))
  do
    echo "For_loop_share: ${file_share_array[$i]}"
    echo "For_loop_fileset: ${fileset_array[$i]}"

    rm -rf "${file_share_array[$i]}"
    mkdir -p "${file_share_array[$i]}"

    while ! showmount -e "${protocol_node}" | grep -q /gpfs/fs1/"${fileset_array[$i]}"; do
      sleep 20
      echo "Waiting for export fileset /gpfs/fs1/${fileset_array[$i]}"
    done

    mount -t nfs4 -o sec=sys "${protocol_node}":/gpfs/fs1/"${fileset_array[$i]}" "${file_share_array[$i]}"

    if mount | grep "${file_share_array[$i]}"; then
      echo "Mount found"
    else
      echo "No mount found"
    fi
  done
fi
