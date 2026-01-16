#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright IBM Corporation 2018

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import argparse
import configparser
import json
import pathlib
import os
import sys


def cleanup(target_file):
    """Cleanup host inventory, group_vars"""
    if os.path.exists(target_file):
        os.remove(target_file)


def read_json_file(json_path):
    """Read inventory as json file"""
    tf_inv = {}
    try:
        with open(json_path) as json_handler:
            try:
                tf_inv = json.load(json_handler)
            except json.decoder.JSONDecodeError:
                print(
                    "Provided terraform inventory file (%s) is not a valid json."
                    % json_path
                )
                sys.exit(1)
    except OSError:
        print("Provided terraform inventory file (%s) does not exist." % json_path)
        sys.exit(1)

    return tf_inv


def write_to_file(filepath, filecontent):
    """Write to specified file"""
    with open(filepath, "w") as file_handler:
        file_handler.write(filecontent)


def prepare_remote_mount_playbook(hosts_config, mount_details):
    """Write to playbook"""
    if ARGUMENTS.using_rest_initialization == "true":
        no_gui = False
    else:
        no_gui = True
    content = """---
# Config remote mount
- hosts: {hosts_config}
  collections:
     - ibm.spectrum_scale
  vars:
    - scale_remotemount_client_gui_username: {compute_gui_username}
    - scale_remotemount_client_gui_password: {compute_gui_password}
    - scale_remotemount_client_gui_hostname: {compute_gui_ip}
    - scale_remotemount_client_no_gui: {compute_gui_state}
    - scale_remotemount_storage_gui_username: {storage_gui_username}
    - scale_remotemount_storage_gui_password: {storage_gui_password}
    - scale_remotemount_storage_gui_hostname: {storage_gui_ip}
    - scale_remotemount_filesystem_name:
        - {{ scale_remotemount_client_filesystem_name: {compute_fs_name}, scale_remotemount_client_remotemount_path: {compute_fs_mount_path}, scale_remotemount_storage_filesystem_name: {storage_fs_name} }}
  pre_tasks:
  roles:
    - remotemount_configure
""".format(
        hosts_config=hosts_config,
        compute_gui_username=mount_details["compute_gui_username"],
        compute_gui_password=mount_details["compute_gui_password"],
        compute_gui_ip=mount_details["compute_gui_ip"],
        compute_gui_state=no_gui,
        storage_gui_username=mount_details["storage_gui_username"],
        storage_gui_password=mount_details["storage_gui_password"],
        storage_gui_ip=mount_details["storage_gui_ip"],
        compute_fs_mount_path=mount_details["compute_fs_mnt"],
        compute_fs_name=mount_details["compute_fs_name"],
        storage_fs_name=mount_details["storage_fs_name"],
    )
    return content


def get_host_format(node):
    """Return host entries"""
    host_format = f"{node['ip_addr']} scale_cluster_quorum={node['is_quorum']} scale_cluster_manager={node['is_manager']} scale_cluster_gui={node['is_gui']} scale_zimon_collector={node['is_collector']} is_nsd_server={node['is_nsd']} is_admin_node={node['is_admin']} ansible_user={node['user']} ansible_ssh_private_key_file={node['key_file']} ansible_python_interpreter=/usr/bin/python3 scale_nodeclass={node['class']} scale_daemon_nodename={node['daemon_nodename']}"
    return host_format


def initialize_node_details(storage_gui_ip, user, key_file):
    """Initialize node details for cluster definition.
    :args: storage_gui_ip (str), user (string), key_file (string)
    """
    node_details, node = [], {}
    node = {
        "ip_addr": storage_gui_ip,
        "is_quorum": True,
        "is_manager": True,
        "is_gui": True,
        "is_collector": True,
        "is_nsd": False,
        "is_admin": True,
        "user": user,
        "key_file": key_file,
        "class": "storagenodegrp",
        "daemon_nodename": storage_gui_ip.split('.')[0]
    }
    node_details.append(get_host_format(node))
    return node_details


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description="Convert terraform inventory "
        "to ansible remote mount inventory format."
    )
    PARSER.add_argument(
        "--compute_tf_inv_path",
        required=True,
        help="Compute cluster terraform inventory file path",
    )
    PARSER.add_argument(
        "--compute_gui_inv_path",
        required=True,
        help="Compute cluster gui inventory file path",
    )
    PARSER.add_argument(
        "--storage_tf_inv_path",
        required=True,
        help="Storage cluster terraform inventory file path",
    )
    PARSER.add_argument(
        "--storage_gui_inv_path",
        required=True,
        help="Storage cluster gui inventory file path",
    )
    PARSER.add_argument(
        "--install_infra_path",
        required=True,
        help="Spectrum Scale install infra clone parent path",
    )
    PARSER.add_argument(
        "--instance_private_key",
        required=True,
        help="Spectrum Scale instances SSH private key path",
    )
    PARSER.add_argument("--using_rest_initialization",
                        help="skips gui configuration")
    PARSER.add_argument("--bastion_user", help="Bastion OS Login username")
    PARSER.add_argument("--bastion_ip", help="Bastion SSH public ip address")
    PARSER.add_argument(
        "--bastion_ssh_private_key", help="Bastion SSH private key path"
    )
    PARSER.add_argument(
        "--compute_cluster_gui_username",
        required=True,
        help="Spectrum Scale compute cluster GUI username",
    )
    PARSER.add_argument(
        "--compute_cluster_gui_password",
        required=True,
        help="Spectrum Scale compute cluster GUI password",
    )
    PARSER.add_argument(
        "--storage_cluster_gui_username",
        required=True,
        help="Spectrum Scale storage cluster GUI username",
    )
    PARSER.add_argument(
        "--storage_cluster_gui_password",
        required=True,
        help="Spectrum Scale storage cluster GUI password",
    )
    PARSER.add_argument("--verbose", action="store_true",
                        help="print log messages")
    ARGUMENTS = PARSER.parse_args()

    # Step-1: Read the inventory file
    COMP_TF = read_json_file(ARGUMENTS.compute_tf_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed compute terraform output: %s" %
              json.dumps(COMP_TF, indent=4))
    STRG_TF = read_json_file(ARGUMENTS.storage_tf_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed storage terraform output: %s" %
              json.dumps(STRG_TF, indent=4))

    # Step-2: Read the GUI inventory file
    COMP_GUI = read_json_file(ARGUMENTS.compute_gui_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed compute terraform output: %s" %
              json.dumps(COMP_GUI, indent=4))
    STRG_GUI = read_json_file(ARGUMENTS.storage_gui_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed storage terraform output: %s" %
              json.dumps(STRG_GUI, indent=4))

    # Step-3: Create playbook
    remote_mount = {}
    remote_mount["compute_gui_ip"] = COMP_GUI["compute_cluster_gui_ip_address"]
    remote_mount["compute_gui_username"] = ARGUMENTS.compute_cluster_gui_username
    remote_mount["compute_gui_password"] = ARGUMENTS.compute_cluster_gui_password
    remote_mount["compute_fs_mnt"] = COMP_TF["compute_cluster_filesystem_mountpoint"]
    remote_mount["compute_fs_name"] = str(
        pathlib.PurePath(COMP_TF["compute_cluster_filesystem_mountpoint"]).stem
    )
    remote_mount["storage_gui_ip"] = STRG_GUI["storage_cluster_gui_ip_address"]
    remote_mount["storage_gui_username"] = ARGUMENTS.storage_cluster_gui_username
    remote_mount["storage_gui_password"] = ARGUMENTS.storage_cluster_gui_password
    remote_mount["storage_fs_name"] = str(
        pathlib.PurePath(STRG_TF["storage_cluster_filesystem_mountpoint"]).stem
    )

    playbook_content = prepare_remote_mount_playbook(
        "scale_nodes", remote_mount)
    write_to_file(
        "%s/%s/remote_mount_cloud_playbook.yaml"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        playbook_content,
    )

    # Step-4: Create hosts
    config = configparser.ConfigParser(allow_no_value=True)
    node_details = initialize_node_details(
        COMP_GUI["compute_cluster_gui_ip_address"],
        "root",
        ARGUMENTS.instance_private_key,
    )
    node_template = ""
    for each_entry in node_details:
        if ARGUMENTS.bastion_ssh_private_key is None:
            node_template = node_template + each_entry + "\n"
        else:
            proxy_command = f"ssh -p 22 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p {ARGUMENTS.bastion_user}@{ARGUMENTS.bastion_ip} -i {ARGUMENTS.bastion_ssh_private_key}"
            each_entry = (
                each_entry
                + " "
                + "ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=30m -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\""
                + proxy_command
                + "\"'"
            )
            node_template = node_template + each_entry + "\n"

    with open(
        "%s/%s/remote_mount_inventory.ini"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        "w",
    ) as configfile:
        configfile.write("[scale_nodes]" + "\n")
        configfile.write(node_template)
