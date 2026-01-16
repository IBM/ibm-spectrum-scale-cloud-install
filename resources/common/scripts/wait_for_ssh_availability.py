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
import subprocess
import sys


def read_json_file(json_path):
    """ Read inventory as json file """
    tf_inv = {}
    try:
        with open(json_path) as json_handler:
            try:
                tf_inv = json.load(json_handler)
            except json.decoder.JSONDecodeError:
                print(
                    "Provided terraform inventory file (%s) is not a valid json." % json_path)
                sys.exit(1)
    except OSError:
        print("Provided terraform inventory file (%s) does not exist." % json_path)
        sys.exit(1)

    return tf_inv


def local_execution(command_list):
    """
    Helper to execute command locally (stores o/p in variable).
    :arg: command_list (list)
    :return: (out, err, command_pipe.returncode)
    """
    sub_command = subprocess.Popen(command_list, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   universal_newlines=True)
    out, err = sub_command.communicate()
    return out, err, sub_command.returncode


def aws_ec2_wait_running(instance_ids, region):
    """
    Wait for EC2 instances to obtain running-ok state.
    :args: region(string), instance_ids(list)
    """
    print("Waiting for instance's (%s) to obtain running-ok state." % instance_ids)
    command = ["aws", "ec2", "wait", "instance-status-ok",
               "--region", region, "--instance-ids"] + instance_ids
    out, err, code = local_execution(command)

    if code:
        print("Instance's did not obtain running-ok state. Existing!")
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(
        description='Wait for instances to achieve okay state.')
    PARSER.add_argument('--tf_inv_path', required=True,
                        help='Terraform inventory file path')
    PARSER.add_argument('--cluster_type', required=True,
                        help='Cluster type (Ex: compute, storage, combined')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    # Step-1: Read the inventory file
    TF = read_json_file(ARGUMENTS.tf_inv_path)
    if ARGUMENTS.verbose:
        print("Parsed terraform output: %s" % json.dumps(TF, indent=4))

    # Step-2: Identify instance id's based cluster_type
    target_instance_ids = []
    if TF['cloud_platform'].upper() == 'AWS':
        if ARGUMENTS.cluster_type == 'compute':
            target_instance_ids = TF['compute_cluster_instance_ids']
            if TF['bastion_instance_id'] != 'None':
                target_instance_ids.append(TF['bastion_instance_id'])
        elif ARGUMENTS.cluster_type == 'storage':
            target_instance_ids = TF['storage_cluster_instance_ids'] + \
                TF['storage_cluster_desc_instance_ids']
            if TF['bastion_instance_id'] != 'None':
                target_instance_ids.append(TF['bastion_instance_id'])
        elif ARGUMENTS.cluster_type == 'combined':
            target_instance_ids = TF['compute_cluster_instance_ids'] + \
                TF['storage_cluster_instance_ids'] + \
                TF['storage_cluster_desc_instance_ids']
            if TF['bastion_instance_id'] != 'None':
                target_instance_ids.append(TF['bastion_instance_id'])
        aws_ec2_wait_running(target_instance_ids, TF['vpc_region'])
