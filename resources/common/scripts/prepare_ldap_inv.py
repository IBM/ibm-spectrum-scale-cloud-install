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


def write_to_file(filepath, filecontent):
    """Write to specified file"""
    with open(filepath, "w") as file_handler:
        file_handler.write(filecontent)


def prepare_ansible_playbook_ldap_server(hosts_config):
    # Write to playbook
    content = """---
# Encryption setup for the ldap server
- hosts: {hosts_config}
  collections:
     - ibm.spectrum_scale
  any_errors_fatal: true
  roles:
     - auth_ldap_server_prepare
"""
    return content.format(hosts_config=hosts_config)


def initialize_cluster_details(cluster_name, ldap_basedns, ldap_admin_password, ldap_user_name, ldap_user_password):
    """ Initialize cluster details.
    :args: cluster_name (string) ldap_basedns (string), ldap_admin_password (string) ldap_user_name (string) ldap_user_password (string)
    """
    cluster_details = {}
    cluster_details['ldap_cluster_prefix'] = cluster_name
    cluster_details['ldap_basedns'] = ldap_basedns
    cluster_details['ldap_admin_password'] = ldap_admin_password
    cluster_details['ldap_user_name'] = ldap_user_name
    cluster_details['ldap_user_password'] = ldap_user_password
    return cluster_details


def get_host_format(node):
    """Return host entries"""
    host_format = f"{node['hostname']} ansible_ssh_private_key_file={node['key_file']}"
    return host_format


def initialize_node_details(ldap_instance_ips, key_file):
    """Initialize node details for cluster definition.
    :args: ldap_instance_ips (list), key_file (string)
    """
    node_details = []
    for ip in ldap_instance_ips:
        node = {
            "hostname": ip,
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
        help="LDAP instances SSH private key path",
    )
    PARSER.add_argument(
        "--ldap_nodes",
        required=True,
        help="LDAP instances terraform inventory file path",
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
    PARSER.add_argument('--ldap_basedns', help='Base domain of ldap',
                        default="null")
    PARSER.add_argument('--ldap_admin_password', help='LDAP admin password',
                        default="null")
    PARSER.add_argument('--ldap_user_name', help='LDAP cluster user',
                        default="null")
    PARSER.add_argument('--ldap_user_password', help='LDAP User password',
                        default="null")
    PARSER.add_argument('--resource_prefix', help='Name of the cluster',
                        default="null")
    PARSER.add_argument("--verbose", action="store_true",
                        help="print log messages")
    ARGUMENTS = PARSER.parse_args()

    cluster_name = ARGUMENTS.resource_prefix
    # Step-1: Read the LDAP Server IP
    LDAP_IP = ARGUMENTS.ldap_nodes

    # Step-4.2: Create LDAP playbook
    if ARGUMENTS.ldap_basedns != "null":
        ldap_playbook_content = prepare_ansible_playbook_ldap_server(
            "ldap_nodes")
        write_to_file("%s/%s/ldap_configure_playbook.yaml" % (ARGUMENTS.install_infra_path,
                                                              "ibm-spectrum-scale-install-infra"), ldap_playbook_content)
    if ARGUMENTS.verbose:
        print("Content of ansible playbook for ldap:\n",
              ldap_playbook_content)

    # Step-5: Create hosts
    config = configparser.ConfigParser(allow_no_value=True)
    node_details = initialize_node_details(
        ARGUMENTS.ldap_nodes.split(','), ARGUMENTS.instance_private_key)
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
        "%s/%s/ldap_inventory.ini"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        "w",
    ) as configfile:
        configfile.write("[ldap_nodes]" + "\n")
        configfile.write(node_template)

    config['all:vars'] = initialize_cluster_details(cluster_name,
                                                    ARGUMENTS.ldap_basedns,
                                                    ARGUMENTS.ldap_admin_password,
                                                    ARGUMENTS.ldap_user_name,
                                                    ARGUMENTS.ldap_user_password)
    with open(
        "%s/%s/ldap_inventory.ini"
        % (ARGUMENTS.install_infra_path, "ibm-spectrum-scale-install-infra"),
        "w",
    ) as configfile:
        configfile.write('[ldap_nodes]' + "\n")
        configfile.write(node_template)
        config.write(configfile)
