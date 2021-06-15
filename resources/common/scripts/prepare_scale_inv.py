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
import os
import pathlib


def create_directory(target_directory):
    pathlib.Path(target_directory).mkdir(parents=True, exist_ok=True)


def read_json_file(json_path):
    """ Read inventory as json file """
    with open(json_path) as json_handler:
        tf_inv = json.load(json_handler)
    return tf_inv


def write_to_file(filepath, filecontent):
    with open(filepath, "w") as file_handler:
        file_handler.write(filecontent)


def prepare_ansible_playbook(hosts_config, cluster_config):
    playbook_content = """---
# Install and config Spectrum Scale on nodes
- hosts: {hosts_config}
  any_errors_fatal: true
  pre_tasks:
     - include_vars: group_vars/{cluster_config}
  roles:
     - core/cluster
     - gui/cluster
     - gui/postcheck
     - zimon/cluster
     - zimon/postcheck
""".format(hosts_config=hosts_config, cluster_config=cluster_config)
    return playbook_content


def initialize_cluster_details(scale_version, cluster_name, gui_username,
                               gui_password, scale_profile_path,
                               scale_replica_config):
    """ Initialize cluster details.
    :args: scale_version (string), cluster_name (string),
           gui_username (string), gui_password (string), scale_profile_path (string),
           scale_replica_config (bool)
    """
    cluster_details = {}
    cluster_details['scale_version'] = scale_version
    cluster_details['scale_cluster_name'] = cluster_name
    cluster_details['scale_service_gui_start'] = "True"
    cluster_details['scale_gui_admin_user'] = gui_username
    cluster_details['scale_gui_admin_password'] = gui_password
    cluster_details['scale_gui_admin_role'] = "Administrator"
    cluster_details['ephemeral_port_range'] = "60000-61000"
    cluster_details['scale_sync_replication_config'] = scale_replica_config
    cluster_details['scale_cluster_profile_name'] = str(
        pathlib.PurePath(scale_profile_path).stem)
    cluster_details['scale_cluster_profile_dir_path'] = str(
        pathlib.PurePath(scale_profile_path).parent)
    return cluster_details


def initialize_node_details(ip_address, node_class, is_nsd_server=False,
                            is_quorum_node=False, is_manager_node=False,
                            is_collector_node=False, is_gui_server=False, is_admin_node=True):
    """ Initialize node details for cluster definition.
    :args: json_data (json), fqdn (string), ip_address (string), node_class (string),
           is_nsd_server (bool), is_quorum_node (bool),
           is_manager_node (bool), is_collector_node (bool), is_gui_server (bool),
           is_admin_node (bool)
    """
    CLUSTER_DEFINITION_JSON['node_details'].append({'ip_address': ip_address,
                                                    'scale_cluster_quorum': is_quorum_node,
                                                    'scale_cluster_manager': is_manager_node,
                                                    'scale_cluster_gui': is_gui_server,
                                                    'scale_zimon_collector': is_collector_node,
                                                    'is_admin_node': is_admin_node,
                                                    'is_nsd_server': is_nsd_server,
                                                    'ansible_user': ansible_user,
                                                    'ansible_ssh_private_key_file': ansible_ssh_private_key_file,
                                                    'scale_nodeclass': node_class})


def initialize_scale_config_details(node_class, param_key, param_value):
    """ Initialize cluster details.
    :args: node_class (string), param_key (string), param_value (string)
    """
    scale_config = {}
    scale_config['scale_config'] = []
    scale_config['scale_config'].append({"nodeclass": node_class,
                                         "params": [{param_key: param_value}]})
    return scale_config


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Convert terraform inventory '
                                                 'to ansible inventory format '
                                                 'install and configuration.')
    PARSER.add_argument('--tf_inv_path', required=True,
                        help='Terraform inventory file path')
    PARSER.add_argument('--install_infra_path', required=True,
                        help='Spectrum Scale install infra clone parent path')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    cluster_type, gui_username, gui_password = None, None, None
    profile_path, replica_config, scale_config = None, None, {}
    # Step-1: Read the inventory file
    TF = read_json_file(ARGUMENTS.tf_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed terraform output: %s" % json.dumps(TF, indent=4))

    # Step-2: Identify the cluster type
    if len(TF['storage_cluster_instance_private_ips']) == 0 and len(TF['compute_cluster_instance_private_ips']) > 0:
        cluster_type = "compute"
        gui_username = TF['compute_cluster_gui_username']
        gui_password = TF['compute_cluster_gui_password']
        profile_path = "%s/computesncparams" % ARGUMENTS.install_infra_path
        replica_config = False
        scale_config = initialize_scale_config_details(
            "computenodegrp", "pagepool", "1G")
    elif len(TF['compute_cluster_instance_private_ips']) == 0 and len(TF['storage_cluster_instance_private_ips']) > 0:
        cluster_type = "storage"
        gui_username = TF['storage_cluster_gui_username']
        gui_password = TF['storage_cluster_gui_password']
        profile_path = "%s/storagesncparams" % ARGUMENTS.install_infra_path
        if len(TF['vpc_availability_zones']) > 1:
            replica_config = True
        else:
            replica_config = False
        scale_config = initialize_scale_config_details(
            "storagenodegrp", "pagepool", "1G")
    else:
        cluster_type = "combined"
        gui_username = TF['storage_cluster_gui_username']
        gui_password = TF['storage_cluster_gui_password']
        profile_path = "%s/scalesncparams" % ARGUMENTS.install_infra_path
        if len(TF['vpc_availability_zones']) > 1:
            replica_config = True
        else:
            replica_config = False
        scale_config = initialize_scale_config_details(
            "storagenodegrp", "pagepool", "1G")

    if ARGUMENTS.verbose:
        print("Identified cluster type: %s" % cluster_type)

    # Step-3: Identify if tie breaker needs to be counted for storage
    if len(TF['vpc_availability_zones']) > 1:
        total_node_count = len(TF['compute_cluster_instance_private_ips']) + \
            len(TF['storage_cluster_desc_instance_private_ips']) + \
            len(TF['storage_cluster_instance_private_ips'])
    else:
        total_node_count = len(TF['compute_cluster_instance_private_ips']) + \
            len(TF['storage_cluster_instance_private_ips'])

    if ARGUMENTS.verbose:
        print("Total node count: ", total_node_count)

    # Determine total number of quorum, manager nodes to be in the cluster
    # manager designates the node as part of the pool of nodes from which
    # file system managers and token managers are selected.
    quorum_count, manager_count = 0, 2
    if total_node_count < 4:
        quorum_count = total_node_count
    elif 4 <= total_node_count < 10:
        quorum_count = 3
    elif 10 <= total_node_count < 19:
        quorum_count = 5
    else:
        quorum_count = 7

    if ARGUMENTS.verbose:
        print("Total quorum count: ", quorum_count)

    # Step-4: Create group_vars directory
    os.chdir("%s/%s" % (ARGUMENTS.install_infra_path,
             "ibm-spectrum-scale-install-infra"))
    create_directory("group_vars")

    # Step-5: Create playbook
    playbook_content = prepare_ansible_playbook(
        "scale_nodes", "%s_cluster_config.yml" % cluster_type)
    write_to_file("%s_cloud_playbook.yml" % cluster_type, playbook_content)

    if ARGUMENTS.verbose:
        print("Content of ansible playbook: ", playbook_content)

    # Step-6: Create hosts
    config = configparser.ConfigParser()
    config['all:vars'] = initialize_cluster_details(TF['scale_version'],
                                                    "%s.%s" % (
                                                        "spectrum-scale", cluster_type),
                                                    gui_username,
                                                    gui_password,
                                                    profile_path,
                                                    replica_config)
    with open("%s_inventory.ini" % cluster_type, 'w') as configfile:
        config.write(configfile)

    if ARGUMENTS.verbose:
        config.read("%s_inventory.ini" % cluster_type)
        for each_key in config['all:vars']:
            print("Content of %s: %s" %
                  (each_key, config.get('all:vars', each_key)))
