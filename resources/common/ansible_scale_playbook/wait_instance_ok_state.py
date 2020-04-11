#!/usr/bin/env python3
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
import re
import subprocess
import sys

# Note: Use cloud_platform flag to alter the wait api per cloud.

def read_tf_inv_file(tf_inv_path):
    """ Read the terraform inventory file """
    tf_inv_list = open(tf_inv_path).read().splitlines()
    return tf_inv_list


def parse_tf_in_json(tf_inv_list):
    """ Parse terraform inventory and prepare dict """
    raw_body, id_list = {}, []
    for each_line in tf_inv_list:
        key_val_match = re.match('(.*)=(.*)', each_line)
        if key_val_match:
            if key_val_match.group(1) == "compute_instances_by_id":
                # Ex: "[i-123da,i-1456da]"
                id_list = re.findall(r'(i-\w+)', key_val_match.group(2))
                raw_body[key_val_match.group(1)] = id_list
            elif key_val_match.group(1) == "compute_instance_desc_id":
                # Ex: "[i-123da,i-1456da]"
                id_list = re.findall(r'(i-\w+)', key_val_match.group(2))
                raw_body[key_val_match.group(1)] = id_list
            elif key_val_match.group(1) == "storage_instances_by_id":
                # Ex: "[i-123da,i-1456da]"
                id_list = re.findall(r'(i-\w+)', key_val_match.group(2))
                raw_body[key_val_match.group(1)] = id_list

    return raw_body


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


def aws_ec2_wait_running(region_name, instance_ids):
    """
    Wait for EC2 instances to obtain running-ok state.
    :args: region_name(string), instance_ids(list)
    """
    print("[CLOUD-DEPLOY] Waiting for instance's to obtain running-ok state.")
    aws_command = ["/usr/local/bin/aws", "ec2", "wait", "instance-status-ok",
                   "--region", region_name, "--instance-ids"] + instance_ids
    out, err, code = local_execution(aws_command)
    if code:
        print("[CLOUD-DEPLOY] Instance's did not obtain running-ok state. Existing!")
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)
    else:
        print("[CLOUD-DEPLOY] Instance's obtained ok state.")


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Wait for instances to achieve okay state.')
    PARSER.add_argument('--tf_inv_path', required=True,
                        help='Terraform inventory file path')
    PARSER.add_argument('--region_name', required=True,
                        help='Region name')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    RAW_TF_INV = read_tf_inv_file(ARGUMENTS.tf_inv_path)
    TF_INV = parse_tf_in_json(RAW_TF_INV)
    if ARGUMENTS.verbose:
        print("Parsed terraform output: %s" % json.dumps(TF_INV, indent=4))

    aws_ec2_wait_running(ARGUMENTS.region_name,
                         TF_INV['compute_instances_by_id'] +
                         TF_INV['compute_instance_desc_id'] +
                         TF_INV['storage_instances_by_id'])
