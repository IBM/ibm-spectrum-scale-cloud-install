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
import json
import pathlib
import re
import os
import sys

# Note: Don't use socket for FQDN resolution.

SCALE_CLUSTER_DEFINITION_PATH = "/ibm-spectrum-scale-install-infra/vars/scale_clusterdefinition.json"  # TODO: FIX
CLUSTER_DEFINITION_JSON = {"scale_cluster": {},
                           "scale_callhome_params": {},
                           "node_details": [],
                           "scale_config": []}


def read_json_file(json_path):
    """ Read inventory as json file """
    tf_inv = {}
    try:
        with open(json_path) as json_handler:
            try:
                tf_inv = json.load(json_handler)
            except json.decoder.JSONDecodeError:
                print("Provided terraform inventory file (%s) is not a valid "
                      "json." % json_path)
                sys.exit(1)
    except OSError:
        print("Provided terraform inventory file (%s) does not exist." % json_path)
        sys.exit(1)

    return tf_inv


def calculate_pagepool(memory_size, max_pagepool_gb):
    """ Calculate pagepool """
    # 1 MiB = 1.048576 MB
    mem_size_mb = int(int(memory_size) * 1.048576)
    # 1 MB = 0.001 GB
    mem_size_gb = int(mem_size_mb * 0.001)
    pagepool_gb = max(int(int(mem_size_gb)*int(25)*0.01), 1)
    if pagepool_gb > int(max_pagepool_gb):
        pagepool = int(max_pagepool_gb)
    else:
        pagepool = pagepool_gb
    return "{}G".format(pagepool)


def initialize_cluster_details(scale_version, cluster_name, username,
                               password, scale_profile_path,
                               scale_replica_config, bastion_ip,
                               bastion_key_file, bastion_user):
    """ Initialize cluster details.
    :args: cluster_name (string), scale_profile_file (string), scale_replica_config (bool)
    """
    CLUSTER_DEFINITION_JSON['scale_cluster']['setuptype'] = "cloud"
    CLUSTER_DEFINITION_JSON['scale_cluster']['enable_perf_reconfig'] = False
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_falpkg_install'] = False
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_version'] = scale_version
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_gui_admin_user'] = username
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_gui_admin_password'] = password
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_gui_admin_role'] = "Administrator"

    CLUSTER_DEFINITION_JSON['scale_cluster']['ephemeral_port_range'] = "60000-61000"
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_cluster_clustername'] = cluster_name
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_service_gui_start'] = True
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_sync_replication_config'] = scale_replica_config
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_cluster_profile_name'] = str(
        pathlib.PurePath(scale_profile_path).stem)
    CLUSTER_DEFINITION_JSON['scale_cluster']['scale_cluster_profile_dir_path'] = str(
        pathlib.PurePath(scale_profile_path).parent)
    if bastion_ip is not None:
        CLUSTER_DEFINITION_JSON['scale_cluster']['scale_jump_host'] = bastion_ip
    if bastion_key_file is not None:
        CLUSTER_DEFINITION_JSON['scale_cluster']['scale_jump_host_private_key'] = bastion_key_file
    if bastion_user is not None:
        CLUSTER_DEFINITION_JSON['scale_cluster']['scale_jump_host_user'] = bastion_user


def initialize_callhome_details():
    CLUSTER_DEFINITION_JSON['scale_callhome_params']['is_enabled'] = False


def initialize_scale_config_details(node_class, param_key, param_value):
    """ Initialize cluster details.
    :args: node_class (string), param_key (string), param_value (string)
    """
    CLUSTER_DEFINITION_JSON['scale_config'].append({"nodeclass": node_class,
                                                    "params": [{param_key: param_value}]})


def set_node_details(fqdn, ip_address, ansible_ssh_private_key_file,
                     node_class, user, is_quorum_node=False,
                     is_manager_node=False, is_gui_server=False,
                     is_collector_node=False, is_nsd_server=False,
                     is_admin_node=True):
    """ Initialize node details for cluster definition.
    :args: json_data (json), fqdn (string), ip_address (string), node_class (string),
           is_nsd_server (bool), is_quorum_node (bool),
           is_manager_node (bool), is_collector_node (bool), is_gui_server (bool),
           is_admin_node (bool)
    """
    CLUSTER_DEFINITION_JSON['node_details'].append({
        'fqdn': fqdn,
        'ip_address': ip_address,
        'ansible_ssh_private_key_file': ansible_ssh_private_key_file,
        'scale_state': 'present',
        'is_nsd_server': is_nsd_server,
        'is_quorum_node': is_quorum_node,
        'is_manager_node': is_manager_node,
        'scale_zimon_collector': is_collector_node,
        'is_gui_server': is_gui_server,
        'is_admin_node': is_admin_node,
        'scale_nodeclass': node_class,
        "os": "rhel8",  # TODO: FIX
        "arch": "x86_64",  # TODO: FIX
        "is_object_store": False,
        "is_nfs": False,
        "is_smb": False,
        "is_hdfs": False,
        "is_protocol_node": False,
        "is_ems_node": False,
        "is_callhome_node": False,
        "is_broker_node": False,
        "is_node_offline": False,
        "is_node_reachable": True,
        "is_node_excluded": False,
        "is_mestor_node": False,
        "scale_daemon_nodename": fqdn,
        "upgrade_prompt": False
    })


def initialize_node_details(az_count, cls_type,
                            compute_private_ips, compute_dns_map,
                            storage_private_ips, storage_dns_map,
                            desc_private_ips, desc_dns_map,
                            quorum_count, user, key_file):
    """ Initialize node details for cluster definition.
    :args: az_count (int), cls_type (string), compute_private_ips (list),
           storage_private_ips (list), desc_private_ips (list),
           quorum_count (int), user (string), key_file (string)
    """
    node_details, node = [], {}
    if cls_type == 'compute':
        start_quorum_assign = quorum_count - 1

        compute_instances = []
        if az_count > 1:
            failure_group1, temp_group, failure_group2, failure_group3 = [], [], [], []
            subnet_pattern = re.compile(
                r'\d{1,3}\.\d{1,3}\.(\d{1,3})\.\d{1,3}')
            subnet1A = subnet_pattern.findall(compute_private_ips[0])
            for each_ip in compute_private_ips:
                current_subnet = subnet_pattern.findall(each_ip)
                if current_subnet[0] == subnet1A[0]:
                    failure_group1.append(each_ip)
                else:
                    temp_group.append(each_ip)

            subnet1A = subnet_pattern.findall(temp_group[0])
            for each_ip in temp_group:
                current_subnet = subnet_pattern.findall(each_ip)
                if current_subnet[0] == subnet1A[0]:
                    failure_group2.append(each_ip)
                else:
                    failure_group3.append(each_ip)

            max_len = max(len(failure_group1), len(
                failure_group2), len(failure_group3))
            idx = 0
            while idx < max_len:
                if idx < len(failure_group1):
                    compute_instances.append(failure_group1[idx])

                if idx < len(failure_group2):
                    compute_instances.append(failure_group2[idx])

                if idx < len(failure_group3):
                    compute_instances.append(failure_group3[idx])

                idx = idx + 1
        else:
            compute_instances = compute_private_ips

        for each_ip in compute_instances:

            if compute_instances.index(each_ip) <= (start_quorum_assign) and \
                    compute_instances.index(each_ip) <= (manager_count - 1):
                if compute_instances.index(each_ip) == 0:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': True, 'is_collector': True, 'is_nsd': False,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "computenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "computenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=True,
                                     is_collector_node=True,
                                     is_nsd_server=False,
                                     is_admin_node=True)

                elif compute_instances.index(each_ip) == 1:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': True, 'is_nsd': False,
                    #         'is_admin': False, 'user': user, 'key_file': key_file,
                    #         'class': "computenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "computenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=True,
                                     is_nsd_server=False,
                                     is_admin_node=False)

                else:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                    #         'is_admin': False, 'user': user, 'key_file': key_file,
                    #         'class': "computenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "computenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=False,
                                     is_nsd_server=False,
                                     is_admin_node=False)

            elif compute_instances.index(each_ip) <= (start_quorum_assign) and \
                    compute_instances.index(each_ip) > (manager_count - 1):

                # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "computenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "computenodegrp",
                                 user,
                                 is_quorum_node=True,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=False,
                                 is_admin_node=False)

            else:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "computenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "computenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=False,
                                 is_admin_node=False)

    elif cls_type == 'storage' and az_count == 1:
        start_quorum_assign = quorum_count - 1
        for each_ip in storage_private_ips:

            if storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) <= (manager_count - 1):
                if storage_private_ips.index(each_ip) == 0:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': True, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}
                    # write_json_file({'storage_cluster_gui_ip_address': each_ip},
                    #                 "%s/%s" % (str(pathlib.PurePath(ARGUMENTS.tf_inv_path).parent),
                    #                           "storage_cluster_gui_details.json"))

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=True,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=True)

                elif storage_private_ips.index(each_ip) == 1:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': False, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=False)

                else:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                    #         'is_gui': False, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': False, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=False,
                                     is_gui_server=False,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=False)

            elif storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) > (manager_count - 1):

                # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=True,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=False)

            else:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=False)

    elif cls_type == 'storage' and az_count > 1:
        for each_ip in desc_private_ips:

            # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
            #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
            #         'is_admin': False, 'user': user, 'key_file': key_file,
            #         'class': "computedescnodegrp"}

            set_node_details(each_ip,
                             each_ip,
                             key_file,
                             "computedescnodegrp",
                             user,
                             is_quorum_node=True,
                             is_manager_node=False,
                             is_gui_server=False,
                             is_collector_node=False,
                             is_nsd_server=True,
                             is_admin_node=False)

        if az_count > 1:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 2 as index starts from 0)
            start_quorum_assign = quorum_count - 2
        else:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 1 as index starts from 0)
            start_quorum_assign = quorum_count - 1

        failure_group1, failure_group2 = [], []

        subnet_pattern = re.compile(r'\d{1,3}\.\d{1,3}\.(\d{1,3})\.\d{1,3}')
        subnet1A = subnet_pattern.findall(storage_private_ips[0])
        for each_ip in storage_private_ips:
            current_subnet = subnet_pattern.findall(each_ip)
            if current_subnet[0] == subnet1A[0]:
                failure_group1.append(each_ip)
            else:
                failure_group2.append(each_ip)

        storage_instances = []
        max_len = max(len(failure_group1), len(failure_group2))
        idx = 0
        while idx < max_len:
            if idx < len(failure_group1):
                storage_instances.append(failure_group1[idx])

            if idx < len(failure_group2):
                storage_instances.append(failure_group2[idx])

            idx = idx + 1

        for each_ip in storage_instances:

            if storage_instances.index(each_ip) <= (start_quorum_assign) and \
                    storage_instances.index(each_ip) <= (manager_count - 1):
                if storage_instances.index(each_ip) == 0:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': True, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=True,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=True)

                    # write_json_file({'storage_cluster_gui_ip_address': each_ip},
                    #                 "%s/%s" % (str(pathlib.PurePath(ARGUMENTS.tf_inv_path).parent),
                    #                            "storage_cluster_gui_details.json"))
                elif storage_instances.index(each_ip) == 1:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=True)

                else:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=False,
                                     is_nsd_server=True,
                                     is_admin_node=True)

            elif storage_instances.index(each_ip) <= (start_quorum_assign) and \
                    storage_instances.index(each_ip) > (manager_count - 1):

                # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': True, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=True,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=True)

            else:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=False)

    elif cls_type == 'combined':
        for each_ip in desc_private_ips:

            # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
            #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
            #         'is_admin': False, 'user': user, 'key_file': key_file,
            #         'class': "computedescnodegrp"}

            set_node_details(each_ip,
                             each_ip,
                             key_file,
                             "computedescnodegrp",
                             user,
                             is_quorum_node=True,
                             is_manager_node=False,
                             is_gui_server=False,
                             is_collector_node=False,
                             is_nsd_server=True,
                             is_admin_node=False)

        if az_count > 1:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 2 as index starts from 0)
            start_quorum_assign = quorum_count - 2
        else:
            # Storage/NSD nodes to be quorum nodes (quorum_count - 1 as index starts from 0)
            start_quorum_assign = quorum_count - 1

        for each_ip in storage_private_ips:

            if storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) <= (manager_count - 1):
                if storage_private_ips.index(each_ip) == 0:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': True, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=True,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=True)

                elif storage_private_ips.index(each_ip) == 1:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': True, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=True,
                                     is_nsd_server=True,
                                     is_admin_node=True)

                else:

                    # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': True,
                    #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                    #         'is_admin': True, 'user': user, 'key_file': key_file,
                    #         'class': "storagenodegrp"}

                    set_node_details(each_ip,
                                     each_ip,
                                     key_file,
                                     "storagenodegrp",
                                     user,
                                     is_quorum_node=True,
                                     is_manager_node=True,
                                     is_gui_server=False,
                                     is_collector_node=False,
                                     is_nsd_server=True,
                                     is_admin_node=True)

            elif storage_private_ips.index(each_ip) <= (start_quorum_assign) and \
                    storage_private_ips.index(each_ip) > (manager_count - 1):

                # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': True, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=True,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=True)

            else:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': True,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "storagenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "storagenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=True,
                                 is_admin_node=False)

        if az_count > 1:
            if len(storage_private_ips) - len(desc_private_ips) >= quorum_count:
                quorums_left = 0
            else:
                quorums_left = quorum_count - \
                    len(storage_private_ips) - len(desc_private_ips)
        else:
            if len(storage_private_ips) > quorum_count:
                quorums_left = 0
            else:
                quorums_left = quorum_count - len(storage_private_ips)

        # Additional quorums assign to compute nodes
        if quorums_left > 0:
            for each_ip in compute_private_ips[0:quorums_left]:

                # node = {'ip_addr': each_ip, 'is_quorum': True, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                #         'is_admin': True, 'user': user, 'key_file': key_file,
                #         'class': "computenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "computenodegrp",
                                 user,
                                 is_quorum_node=True,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=False,
                                 is_admin_node=True)

            for each_ip in compute_private_ips[quorums_left:]:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "computenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "computenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=False,
                                 is_admin_node=False)

        if quorums_left == 0:
            for each_ip in compute_private_ips:

                # node = {'ip_addr': each_ip, 'is_quorum': False, 'is_manager': False,
                #         'is_gui': False, 'is_collector': False, 'is_nsd': False,
                #         'is_admin': False, 'user': user, 'key_file': key_file,
                #         'class': "computenodegrp"}

                set_node_details(each_ip,
                                 each_ip,
                                 key_file,
                                 "computenodegrp",
                                 user,
                                 is_quorum_node=False,
                                 is_manager_node=False,
                                 is_gui_server=False,
                                 is_collector_node=False,
                                 is_nsd_server=False,
                                 is_admin_node=False)


def get_disks_list(az_count, disk_mapping, storage_dns_map, desc_disk_mapping, desc_dns_map, fs_mount):
    """ Initialize disk list. """
    disks_list = []

    # Map storage nodes to failure groups based on AZ and subnet variations
    failure_group1, failure_group2 = [], []
    if az_count == 1:
        # Single AZ, just split list equally
        num_storage_nodes = len(list(disk_mapping))
        mid_index = num_storage_nodes//2
        failure_group1 = list(disk_mapping)[:mid_index]
        failure_group2 = list(disk_mapping)[mid_index:]
    else:
        # Multi AZ, split based on subnet match
        subnet_pattern = re.compile(r'\d{1,3}\.\d{1,3}\.(\d{1,3})\.\d{1,3}')
        subnet1A = subnet_pattern.findall(list(disk_mapping)[0])
        for each_ip in disk_mapping:
            current_subnet = subnet_pattern.findall(each_ip)
            if current_subnet[0] == subnet1A[0]:
                failure_group1.append(each_ip)
            else:
                failure_group2.append(each_ip)

    storage_instances = []
    max_len = max(len(failure_group1), len(failure_group2))
    idx = 0
    while idx < max_len:
        if idx < len(failure_group1):
            storage_instances.append(failure_group1[idx])

        if idx < len(failure_group2):
            storage_instances.append(failure_group2[idx])

        idx = idx + 1

    # Prepare dict of disks / NSD list
    # "nsd": "nsd1",
    # "device": "/dev/xvdf",
    # "size": 536870912000,
    # "failureGroup": "1",
    # "filesystem": "FS1",
    # "servers": "ip-10-0-3-10.ap-south-1.compute.internal",
    # "usage": "dataAndMetadata",
    # "pool": "system"

    nsd_count = 1
    for each_ip, disk_per_ip in disk_mapping.items():

        if each_ip in failure_group1:
            for each_disk in disk_per_ip:

                # disks_list.append({"device": each_disk,
                #                    "failureGroup": 1, "servers": each_ip,
                #                    "usage": "dataAndMetadata", "pool": "system"})

                # TODO: FIX Include disk "size"
                disks_list.append({
                    "nsd": "nsd_" + each_ip.replace(".", "_") + "_" + os.path.basename(each_disk),
                    "filesystem": pathlib.PurePath(fs_mount).name,
                    "device": each_disk,
                    "failureGroup": 1,
                    "servers": each_ip,
                    "usage": "dataAndMetadata",
                    "pool": "system"
                })
                nsd_count = nsd_count + 1

        if each_ip in failure_group2:
            for each_disk in disk_per_ip:

                # disks_list.append({"device": each_disk,
                #                    "failureGroup": 2, "servers": each_ip,
                #                    "usage": "dataAndMetadata", "pool": "system"})

                # TODO: FIX Include disk "size"
                disks_list.append({
                    "nsd": "nsd_" + each_ip.replace(".", "_") + "_" + os.path.basename(each_disk),
                    "filesystem": pathlib.PurePath(fs_mount).name,
                    "device": each_disk,
                    "failureGroup": 2,
                    "servers": each_ip,
                    "usage": "dataAndMetadata",
                    "pool": "system"
                })
                nsd_count = nsd_count + 1

    # Append "descOnly" disk details
    if len(desc_disk_mapping.keys()):
        ip_address = list(desc_disk_mapping.keys())[0]
        device = list(desc_disk_mapping.values())[0][0]

        # TODO: FIX Include disk "size"
        disks_list.append({"nsd": "nsd_" + ip_address.replace(".", "_") + "_" + os.path.basename(device),
                           "filesystem": pathlib.PurePath(fs_mount).name,
                           "device": device,
                           "failureGroup": 3,
                           "servers": ip_address,
                           "usage": "descOnly",
                           "pool": "system"})

    return disks_list


def initialize_scale_storage_details(az_count, fs_mount, block_size):
    """ Initialize storage details.
    :args: az_count (int), fs_mount (string), block_size (string),
           disks_list (list)
    """
    storage = []
    if az_count > 1:
        data_replicas = 2
        metadata_replicas = 2
    else:
        data_replicas = 1
        metadata_replicas = 2

    # "scale_filesystem": [
    #    {
    #        "filesystem": "FS1",
    #        "defaultMountPoint": "/ibm/FS1",
    #        "blockSize": "4M",
    #        "defaultDataReplicas": "1",
    #        "maxDataReplicas": "2",
    #        "defaultMetadataReplicas": "1",
    #        "maxMetadataReplicas": "2",
    #        "scale_fal_enable": "False",
    #        "logfileset": ".audit_log",
    #        "retention": "365"
    #    }
    # ]

    # TODO: FIX. Add "automaticMountOption": "true"
    storage.append({"filesystem": pathlib.PurePath(fs_mount).name,
                    "defaultMountPoint": fs_mount,
                    "blockSize": block_size,
                    "defaultDataReplicas": data_replicas,
                    "maxDataReplicas": "2",
                    "defaultMetadataReplicas": metadata_replicas,
                    "maxMetadataReplicas": "2",
                    "scale_fal_enable": False,
                    "logfileset": ".audit_log",
                    "retention": "365"})
    return storage


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Convert terraform inventory '
                                                 'to ansible inventory format '
                                                 'install and configuration.')
    PARSER.add_argument('--tf_inv_path', required=True,
                        help='Terraform inventory file path')
    PARSER.add_argument('--install_infra_path', required=True,
                        help='Spectrum Scale install infra clone parent path')
    PARSER.add_argument('--instance_private_key', required=True,
                        help='Spectrum Scale instances SSH private key path')
    PARSER.add_argument('--bastion_user',
                        help='Bastion OS Login username')
    PARSER.add_argument('--bastion_ip',
                        help='Bastion SSH public ip address')
    PARSER.add_argument('--bastion_ssh_private_key',
                        help='Bastion SSH private key path')
    PARSER.add_argument('--memory_size', help='Instance memory size')
    PARSER.add_argument('--max_pagepool_gb', help='maximum pagepool size in GB',
                        default=1)
    PARSER.add_argument('--using_packer_image', help='skips gpfs rpm copy')
    PARSER.add_argument('--using_rest_initialization',
                        help='skips gui configuration')
    PARSER.add_argument('--gui_username', required=True,
                        help='Spectrum Scale GUI username')
    PARSER.add_argument('--gui_password', required=True,
                        help='Spectrum Scale GUI password')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')

    ARGUMENTS = PARSER.parse_args()

    # Step-1: Read the inventory file
    TF = read_json_file(ARGUMENTS.tf_inv_path)

    if ARGUMENTS.verbose:
        print("Parsed terraform output: %s" % json.dumps(TF, indent=4))

    # Step-2: Identify the cluster type
    if len(TF['storage_cluster_instance_private_ips']) == 0 and \
       len(TF['compute_cluster_instance_private_ips']) > 0:
        cluster_type = "compute"
        gui_username = ARGUMENTS.gui_username
        gui_password = ARGUMENTS.gui_password
        profile_path = "%s/computesncparams" % ARGUMENTS.install_infra_path
        replica_config = False
        pagepool_size = calculate_pagepool(ARGUMENTS.memory_size,
                                           ARGUMENTS.max_pagepool_gb)
        scale_config = initialize_scale_config_details("computenodegrp",
                                                       "pagepool",
                                                       pagepool_size)
    elif len(TF['compute_cluster_instance_private_ips']) == 0 and \
            len(TF['storage_cluster_instance_private_ips']) > 0 and \
            len(TF['vpc_availability_zones']) == 1:
        # single az storage cluster
        cluster_type = "storage"
        gui_username = ARGUMENTS.gui_username
        gui_password = ARGUMENTS.gui_password
        profile_path = "%s/storagesncparams" % ARGUMENTS.install_infra_path
        replica_config = bool(len(TF['vpc_availability_zones']) > 1)
        pagepool_size = calculate_pagepool(ARGUMENTS.memory_size,
                                           ARGUMENTS.max_pagepool_gb)
        scale_config = initialize_scale_config_details("storagenodegrp",
                                                       "pagepool",
                                                       pagepool_size)
    elif len(TF['compute_cluster_instance_private_ips']) == 0 and \
            len(TF['storage_cluster_instance_private_ips']) > 0 and \
            len(TF['vpc_availability_zones']) > 1 and \
            len(TF['storage_cluster_desc_instance_private_ips']) > 0:
        # multi az storage cluster
        cluster_type = "storage"
        gui_username = ARGUMENTS.gui_username
        gui_password = ARGUMENTS.gui_password
        profile_path = "%s/storagesncparams" % ARGUMENTS.install_infra_path
        replica_config = bool(len(TF['vpc_availability_zones']) > 1)
        pagepool_size = calculate_pagepool(ARGUMENTS.memory_size,
                                           ARGUMENTS.max_pagepool_gb)
        scale_config = initialize_scale_config_details("storagenodegrp",
                                                       "pagepool",
                                                       pagepool_size)
        scale_config = initialize_scale_config_details("computedescnodegrp",
                                                       "pagepool",
                                                       pagepool_size)
    else:
        cluster_type = "combined"
        gui_username = ARGUMENTS.gui_username
        gui_password = ARGUMENTS.gui_password
        profile_path = "%s/scalesncparams" % ARGUMENTS.install_infra_path
        replica_config = bool(len(TF['vpc_availability_zones']) > 1)
        pagepool_size = calculate_pagepool(
            ARGUMENTS.memory_size, ARGUMENTS.max_pagepool_gb)
        if len(TF['vpc_availability_zones']) == 1:
            scale_config = initialize_scale_config_details(
                "storagenodegrp", "pagepool", pagepool_size)
            scale_config = initialize_scale_config_details(
                "computenodegrp", "pagepool", pagepool_size)
        else:
            scale_config = initialize_scale_config_details(
                "storagenodegrp", "pagepool", pagepool_size)
            scale_config = initialize_scale_config_details(
                "computenodegrp", "pagepool", pagepool_size)
            scale_config = initialize_scale_config_details(
                "computedescnodegrp", "pagepool", pagepool_size)

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

    # Define cluster details
    if TF['resource_prefix']:
        cluster_name = TF['resource_prefix']
    else:
        cluster_name = "%s.%s" % ("spectrum-scale", cluster_type)

    initialize_cluster_details(TF['scale_version'],
                               cluster_name,
                               gui_username,
                               gui_password,
                               profile_path,
                               replica_config,
                               ARGUMENTS.bastion_ip,
                               ARGUMENTS.bastion_ssh_private_key,
                               ARGUMENTS.bastion_user)

    initialize_callhome_details()

    # Step-5: Create hosts
    initialize_node_details(len(TF['vpc_availability_zones']), cluster_type,
                            TF['compute_cluster_instance_private_ips'],
                            TF['compute_cluster_instance_private_dns_ip_map'],
                            TF['storage_cluster_instance_private_ips'],
                            TF['storage_cluster_instance_private_dns_ip_map'],
                            TF['storage_cluster_desc_instance_private_ips'],
                            TF['storage_cluster_desc_instance_private_dns_ip_map'],
                            quorum_count, "root", ARGUMENTS.instance_private_key)

    if cluster_type in ['storage', 'combined']:
        disks_list = get_disks_list(len(TF['vpc_availability_zones']),
                                    TF['storage_cluster_with_data_volume_mapping'],
                                    TF['storage_cluster_instance_private_dns_ip_map'],
                                    TF['storage_cluster_desc_data_volume_mapping'],
                                    TF['storage_cluster_desc_instance_private_dns_ip_map'],
                                    TF['storage_cluster_filesystem_mountpoint'])

        scale_storage = initialize_scale_storage_details(len(TF['vpc_availability_zones']),
                                                         TF['storage_cluster_filesystem_mountpoint'],
                                                         TF['filesystem_block_size'])

        CLUSTER_DEFINITION_JSON.update({"scale_filesystem": scale_storage})
        CLUSTER_DEFINITION_JSON.update({"scale_disks": disks_list})

    if ARGUMENTS.verbose:
        print("Content of scale_clusterdefinition.json: ",
              json.dumps(CLUSTER_DEFINITION_JSON, indent=4))

    # Write json content
    if ARGUMENTS.verbose:
        print("Writing cloud infrastructure details to: ",
              ARGUMENTS.install_infra_path.rstrip('/') + SCALE_CLUSTER_DEFINITION_PATH)

    # Create vars directory if missing
    if not os.path.exists(ARGUMENTS.install_infra_path.rstrip('/') + SCALE_CLUSTER_DEFINITION_PATH):
        os.makedirs(os.path.dirname(ARGUMENTS.install_infra_path.rstrip(
            '/') + SCALE_CLUSTER_DEFINITION_PATH), exist_ok=True)

    with open(ARGUMENTS.install_infra_path.rstrip('/') + SCALE_CLUSTER_DEFINITION_PATH, 'w') as json_fh:
        json.dump(CLUSTER_DEFINITION_JSON, json_fh, indent=4)

    if ARGUMENTS.verbose:
        print("Completed writing cloud infrastructure details to: ",
              ARGUMENTS.install_infra_path.rstrip('/') + SCALE_CLUSTER_DEFINITION_PATH)
