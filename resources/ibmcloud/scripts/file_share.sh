#!/bin/bash

file_name="client_inventory.ini"

if [ -e "$file_name" ]; then
    echo "File exists. Deleting..."
    rm "$file_name"
    echo "File deleted."
else
    echo "File does not exist."
fi

IFS=' ' read -ra client_node <<< "$client_nodes"
IFS=' ' read -ra protocol_instance_name <<< "$protocol_instance_names"
IFS=' ' read -ra custom_file_share <<< "$custom_file_shares"
IFS=' ' read -ra list_of_fileset <<< "$list_of_filesets"

key="ansible_ssh_private_key_file=/opt/IBM/ibm-spectrumscale-cloud-deploy/compute_key/id_rsa"

echo "[scale_nodes]" >> client_inventory.ini

for ((i=0; i<${#client_node[@]}; i++)); do
    echo "${client_node[i]} $key" >> client_inventory.ini
done

protocol_instance_array=("${protocol_instance_name[@]}")
file_share_array=("${custom_file_share[@]}")
fileset_array=("${list_of_fileset[@]}")

echo "[all:vars]" >> client_inventory.ini

echo -n "proto_nodes = [" >> client_inventory.ini
for ((i=0; i<${#protocol_instance_array[@]}; i++))
do
    if [ $i -eq $((${#protocol_instance_array[@]}-1)) ]; then
        echo -n "\"${protocol_instance_array[$i]}\"" >> client_inventory.ini
    else
        echo -n "\"${protocol_instance_array[$i]}\", " >> client_inventory.ini
    fi
done
echo "]" >> client_inventory.ini

echo -n "custom_file_share = [" >> client_inventory.ini
for ((i=0; i<${#file_share_array[@]}; i++))
do
    if [ $i -eq $((${#file_share_array[@]}-1)) ]; then
        echo -n "\"${file_share_array[$i]}\"" >> client_inventory.ini
    else
        echo -n "\"${file_share_array[$i]}\", " >> client_inventory.ini
    fi
done
echo "]" >> client_inventory.ini

echo -n "list_of_fileset = [" >> client_inventory.ini
for ((i=0; i<${#fileset_array[@]}; i++))
do
    if [ $i -eq $((${#fileset_array[@]}-1)) ]; then
        echo -n "\"${fileset_array[$i]}\"" >> client_inventory.ini
    else
        echo -n "\"${fileset_array[$i]}\", " >> client_inventory.ini
    fi
done
echo "]" >> client_inventory.ini
