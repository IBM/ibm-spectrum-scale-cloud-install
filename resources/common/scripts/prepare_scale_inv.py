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
import yaml


def create_directory(target_directory):
    """ Create specified directory """
    pathlib.Path(target_directory).mkdir(parents=True, exist_ok=True)


def read_json_file(json_path):
    """ Read inventory as json file """
    with open(json_path) as json_handler:
        tf_inv = json.load(json_handler)
    return tf_inv


def write_to_file(filepath, filecontent):
    """ Write to specified file """
    with open(filepath, "w") as file_handler:
        file_handler.write(filecontent)


def prepare_ansible_playbook(hosts_config, cluster_config):
    """ Write to playbook """
    content = """---
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
    return content


def initialize_cluster_details(scale_version, cluster_name, username,
                               password, scale_profile_path,
                               scale_replica_config):
    """ Initialize cluster details.
    :args: scale_version (string), cluster_name (string),
           username (string), password (string), scale_profile_path (string),
           scale_replica_config (bool)
    """
    cluster_details = {}
    cluster_details['scale_version'] = scale_version
    cluster_details['scale_cluster_name'] = cluster_name
    cluster_details['scale_service_gui_start'] = "True"
    cluster_details['scale_gui_admin_user'] = username
    cluster_details['scale_gui_admin_password'] = password
    cluster_details['scale_gui_admin_role'] = "Administrator"
    cluster_details['ephemeral_port_range'] = "60000-61000"
    cluster_details['scale_sync_replication_config'] = scale_replica_config
    cluster_details['scale_cluster_profile_name'] = str(
        pathlib.PurePath(scale_profile_path).stem)
    cluster_details['scale_cluster_profile_dir_path'] = str(
        pathlib.PurePath(scale_profile_path).parent)
    return cluster_details


def get_host_format(node):
    """ Return host entries """
    host_format = f"{node['ip_addr']} scale_cluster_quorum={node['is_quorum']} scale_cluster_manager={node['is_manager']} scale_cluster_gui={node['is_gui']} scale_zimon_collector={node['is_collector']} is_nsd_server={node['is_nsd']} is_admin_node={node['is_admin']} ansible_user={node['user']} ansible_ssh_private_key_file={node['key_file']} scale_nodeclass={node['class']}"
    return host_format


def initialize_node_details(az_count, cluster_type, compute_private_ips,
                            storage_private_ips, desc_private_ips, quorum_count,
                            user, key_file):
    """ Initialize node details for cluster definition.
    :args: az_count (int), cluster_type (string), compute_private_ips (list),
           storage_private_ips (list), desc_private_ips (list),
           quorum_count (int), user, key_file
    """
    node_details = []
    if cluster_type == 'compute':
        for each_ip in compute_private_ips:
            node = {}
            if compute_private_ips.index(each_ip) == 0:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                        'is_gui': True, 'is_collector': True, 'is_nsd': False,
                        'is_admin': True, 'user': user, 'key_file': key_file,
                        'class': "computenodegrp"}
            elif compute_private_ips.index(each_ip) == 1:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                        'is_gui': False, 'is_collector': True, 'is_nsd': False,
                        'is_admin': False, 'user': user, 'key_file': key_file,
                        'class': "computenodegrp"}
            else:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                        'is_gui': False, 'is_collector': False, 'is_nsd': False,
                        'is_admin': False, 'user': user, 'key_file': key_file,
                        'class': "computenodegrp"}
            node_details.append(get_host_format(node))
    elif cluster_type == 'storage' and az_count == 1:
        for each_ip in storage_private_ips:
            node = {}
            if storage_private_ips.index(each_ip) == 0:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                        'is_gui': True, 'is_collector': True, 'is_nsd': True,
                        'is_admin': True, 'user': user, 'key_file': key_file,
                        'class': "storagenodegrp"}
            elif storage_private_ips.index(each_ip) == 1:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                        'is_gui': False, 'is_collector': True, 'is_nsd': True,
                        'is_admin': False, 'user': user, 'key_file': key_file,
                        'class': "storagenodegrp"}
            else:
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                        'is_gui': False, 'is_collector': True, 'is_nsd': True,
                        'is_admin': False, 'user': user, 'key_file': key_file,
                        'class': "storagenodegrp"}
            node_details.append(get_host_format(node))
    elif cluster_type == 'storage' and az_count > 1:
        for each_ip in desc_private_ips:
            node = {}
            node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                    'is_gui': False, 'is_collector': False, 'is_nsd': True,
                    'is_admin': False, 'user': user, 'key_file': key_file,
                    'class': "computedescnodegrp"}
            node_details.append(get_host_format(node))

        if az_count > 1:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 2 as index starts from 0)
            start_quorum_assign = quorum_count - 2
        else:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 1 as index starts from 0)
            start_quorum_assign = quorum_count - 1

        for each_ip in storage_private_ips:
            node = {}
            if storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) <= (manager_count - 1):
                if storage_private_ips.index(each_ip) == 0:
                    node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                            'is_gui': True, 'is_collector': True, 'is_nsd': True,
                            'is_admin': True, 'user': user, 'key_file': key_file,
                            'class': "storagenodegrp"}
                elif storage_private_ips.index(each_ip) == 1:
                    node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                            'is_gui': False, 'is_collector': True, 'is_nsd': True,
                            'is_admin': True, 'user': user, 'key_file': key_file,
                            'class': "storagenodegrp"}
                else:
                    node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                            'is_gui': False, 'is_collector': False, 'is_nsd': True,
                            'is_admin': True, 'user': user, 'key_file': key_file,
                            'class': "storagenodegrp"}
            elif storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) > (manager_count - 1):
                node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                        'is_gui': False, 'is_collector': False, 'is_nsd': True,
                        'is_admin': True, 'user': user, 'key_file': key_file,
                        'class': "storagenodegrp"}
            else:
                node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                        'is_gui': False, 'is_collector': False, 'is_nsd': True,
                        'is_admin': False, 'user': user, 'key_file': key_file,
                        'class': "storagenodegrp"}

            node_details.append(get_host_format(node))
    return node_details


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
        replica_config = bool(len(TF['vpc_availability_zones']) > 1)
        scale_config = initialize_scale_config_details(
            "storagenodegrp", "pagepool", "1G")
    else:
        cluster_type = "combined"
        gui_username = TF['storage_cluster_gui_username']
        gui_password = TF['storage_cluster_gui_password']
        profile_path = "%s/scalesncparams" % ARGUMENTS.install_infra_path
        replica_config = bool(len(TF['vpc_availability_zones']) > 1)
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
    create_directory("%s/%s/%s" % (ARGUMENTS.install_infra_path,
                                   "ibm-spectrum-scale-install-infra",
                                   "group_vars"))

    # Step-5: Create playbook
    playbook_content = prepare_ansible_playbook(
        "scale_nodes", "%s_cluster_config.yml" % cluster_type)
    write_to_file("/%s/%s/%s_cloud_playbook.yml" % (ARGUMENTS.install_infra_path,
                                                    "ibm-spectrum-scale-install-infra",
                                                    cluster_type), playbook_content)

    if ARGUMENTS.verbose:
        print("Content of ansible playbook:\n", playbook_content)

    # Step-6: Create group_vars
    with open("%s/%s/%s/%s" % (ARGUMENTS.install_infra_path,
                               "ibm-spectrum-scale-install-infra",
                               "group_vars",
                               "%s_cluster_config.yaml" % cluster_type), 'w') as groupvar:
        yaml.dump(scale_config, groupvar, default_flow_style=False)
    if ARGUMENTS.verbose:
        print("group_vars content:\n%s" % yaml.dump(
            scale_config, default_flow_style=False))

    # Step-7: Create hosts
    config = configparser.ConfigParser(allow_no_value=True)
    node_details = initialize_node_details(len(TF['vpc_availability_zones']), cluster_type,
                                           TF['compute_cluster_instance_private_ips'],
                                           TF['storage_cluster_instance_private_ips'],
                                           TF['storage_cluster_desc_instance_private_ips'],
                                           quorum_count, "root", "key")
    node_template = ""
    for each_entry in node_details:
        node_template = node_template + each_entry + "\n"

    config['all:vars'] = initialize_cluster_details(TF['scale_version'],
                                                    "%s.%s" % (
                                                        "spectrum-scale", cluster_type),
                                                    gui_username,
                                                    gui_password,
                                                    profile_path,
                                                    replica_config)
    with open("%s/%s/%s_inventory.ini" % (ARGUMENTS.install_infra_path,
                                          "ibm-spectrum-scale-install-infra",
                                          cluster_type), 'w') as configfile:
        configfile.write('[scale_nodes]' + "\n")
        configfile.write(node_template)
        config.write(configfile)

    if ARGUMENTS.verbose:
        config.read("%s/%s/%s_inventory.ini" % (ARGUMENTS.install_infra_path,
                                                "ibm-spectrum-scale-install-infra",
                                                cluster_type))
        print("Content of %s/%s/%s_inventory.ini" % (ARGUMENTS.install_infra_path,
                                                     "ibm-spectrum-scale-install-infra",
                                                     cluster_type))
        print('[scale_nodes]')
        print(node_template)
        print('[all:vars]')
        for each_key in config['all:vars']:
            print("%s: %s" % (each_key, config.get('all:vars', each_key)))
