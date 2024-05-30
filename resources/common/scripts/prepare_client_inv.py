#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright IBM Corporation 2023

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


def prepare_ansible_playbook_mount_fileset_client(hosts_config):
    """ Write to playbook """
    content = """---
# Mounting mount filesets on client nodes
- hosts: {hosts_config}
  collections:
     - ibm.spectrum_scale
  any_errors_fatal: true

  roles:
     - nfs_client_prepare
     - nfs_client_configure
     - {{ role: auth_configure, when: enable_ldap }}
""".format(hosts_config=hosts_config)
    return content


def initialize_cluster_details(protocol_cluster_reserved_names, storage_cluster_filesystem_mountpoint, filesets, enable_ldap, ldap_basedns, ldap_server, ldap_admin_password):
    """ Initialize cluster details.
    :args: protocol_cluster_reserved_names (string), filesets (string)
    """
    filesets_list = []
    for mount_path in filesets.keys():
        name = mount_path.split('/')[-1]
        filesets_list.append({'name': name, 'mount_path': mount_path})

    cluster_details = {}
    cluster_details['protocol_cluster_reserved_names'] = protocol_cluster_reserved_names
    cluster_details['storage_cluster_filesystem_mountpoint'] = storage_cluster_filesystem_mountpoint
    cluster_details['filesets'] = filesets_list
    cluster_details['enable_ldap'] = enable_ldap
    cluster_details['ldap_basedns'] = ldap_basedns
    cluster_details['ldap_server'] = ldap_server
    cluster_details['ldap_admin_password'] = ldap_admin_password
    return cluster_details


def get_host_format(node):
    """Return host entries"""
    host_format = f"{node['hostname']} ansible_ssh_private_key_file={node['key_file']}"
    return host_format


def initialize_node_details(client_cluster_instance_names, key_file):
    """Initialize node details for cluster definition.
    :args:hostname (string), key_file (string)
    """
    node_details, node = [], {}
    for hostname in client_cluster_instance_names:
        node = {
            "hostname": hostname,
            "key_file": key_file,
        }
        node_details.append(get_host_format(node))
    return node_details


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description="Convert terraform inventory "
        "to ansible remote mount inventory format."
    )
    PARSER.add_argument(
        "--instance_private_key",
        required=True,
        help="Client instances SSH private key path",
    )
    PARSER.add_argument(
        "--client_tf_inv_path",
        required=True,
        help="Storage cluster terraform inventory file path",
    )
    PARSER.add_argument(
        "--install_infra_path",
        required=True,
        help="Spectrum Scale install infra clone parent path",
    )
    PARSER.add_argument(
        "--bastion_user",
        help="Bastion OS Login username",
    )
    PARSER.add_argument(
        "--bastion_ip",
        help="Bastion SSH public ip address",
    )
    PARSER.add_argument(
        "--bastion_ssh_private_key",
        help="Bastion SSH private key path",
    )
    PARSER.add_argument("--verbose", action="store_true",
                        help="print log messages")
    PARSER.add_argument("--enable_ldap", help="Enabling the LDAP",  default="false")
    PARSER.add_argument("--ldap_basedns", help="Base domain of LDAP", default="null")
    PARSER.add_argument("--ldap_server", help="LDAP Server IP", default="null")
    PARSER.add_argument("--ldap_admin_password", help="LDAP Admin Password", default="null")
    ARGUMENTS = PARSER.parse_args()

    # Step-1: Read the inventory file
    STRG_TF = read_json_file(ARGUMENTS.client_tf_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed storage terraform output: %s" %
              json.dumps(STRG_TF, indent=4))

    # Step-2: Cleanup the Client Playbook file
    cleanup("%s/%s/%s_mount_cloud_playbook.yaml" % (ARGUMENTS.install_infra_path,
                                                    "ibm-spectrum-scale-install-infra",
                                                    "client"))
    # Step-3: Cleanup the Clinet inventory file
    cleanup("%s/%s/%s_mount_inventory.ini" % (ARGUMENTS.install_infra_path,
                                              "ibm-spectrum-scale-install-infra",
                                              "client"))

    # Step-4: Create playbook
    playbook_content = prepare_ansible_playbook_mount_fileset_client(
        "client_nodes")
    write_to_file(
        "%s/%s/client_cloud_playbook.yaml"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        playbook_content,
    )

    # Step-5: Create hosts
    config = configparser.ConfigParser(allow_no_value=True)
    node_details = initialize_node_details(
        STRG_TF['client_cluster_instance_names'],
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
        "%s/%s/client_inventory.ini"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        "w",
    ) as configfile:
        configfile.write("[client_nodes]" + "\n")
        configfile.write(node_template)

    config['all:vars'] = initialize_cluster_details(STRG_TF['protocol_cluster_reserved_names'],
                                                    STRG_TF['storage_cluster_filesystem_mountpoint'],
                                                    STRG_TF['filesets'],
                                                    ARGUMENTS.enable_ldap,
                                                    ARGUMENTS.ldap_basedns,
                                                    ARGUMENTS.ldap_server,
                                                    ARGUMENTS.ldap_admin_password)
    with open(
        "%s/%s/client_inventory.ini"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        "w",
    ) as configfile:
        configfile.write('[client_nodes]' + "\n")
        configfile.write(node_template)
        config.write(configfile)