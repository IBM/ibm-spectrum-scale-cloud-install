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
import pathlib
import re

REMOTE_MOUNT_DEFINITION_JSON = {}

def read_tf_inv_file(tf_inv_path):
    """ Read the terraform inventory json file """
    with open(tf_inv_path) as json_handler:
        tf_inv = json.load(json_handler)
    return tf_inv

if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Convert terraform inventory '
                                                 'to ansible inventory format '
                                                 'install and configuration.')
    PARSER.add_argument('--compute_tf_inv_path', required=True,
                        help='Terraform compute inventory file path')
    PARSER.add_argument('--storage_tf_inv_path', required=True,
                        help='Terraform storage inventory file path')
    PARSER.add_argument('--remote_mount_def_path', required=True,
                        help='Spectrum Scale remote mount json path')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    COMPUTETF_INV = read_tf_inv_file(ARGUMENTS.compute_tf_inv_path)
    STORAGETF_INV = read_tf_inv_file(ARGUMENTS.storage_tf_inv_path)

    if ARGUMENTS.verbose:
        print("Parsed terraform output: %s" % json.dumps(COMPUTETF_INV, indent=4))
        print("Parsed terraform output: %s" % json.dumps(STORAGETF_INV, indent=4))


    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount'] = {}

    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['client_gui_username'] = COMPUTETF_INV['compute_gui_username']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['client_gui_password'] = COMPUTETF_INV['compute_gui_password']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['client_gui_hostname'] = COMPUTETF_INV['client_gui_hostname']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['client_filesystem_name'] = "remotefs1"
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['client_remotemount_path'] = "/mnt"

    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['storage_gui_username'] = STORAGETF_INV['storage_gui_username']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['storage_gui_password'] = STORAGETF_INV['storage_gui_password']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['storage_gui_hostname'] = STORAGETF_INV['storage_gui_hostname']
    REMOTE_MOUNT_DEFINITION_JSON['scale_remotemount']['storage_filesystem_name'] = pathlib.PurePath(STORAGETF_INV['filesystem_mountpoint']).name

    if ARGUMENTS.verbose:
        print("Content of remote_mount_definition.json: ",
              json.dumps(REMOTE_MOUNT_DEFINITION_JSON, indent=4))

    # Write json content
    if ARGUMENTS.verbose:
        print("Writing cloud infrastructure details to: ", ARGUMENTS.remote_mount_def_path)
    with open(ARGUMENTS.remote_mount_def_path, 'w') as json_fh:
        json.dump(REMOTE_MOUNT_DEFINITION_JSON, json_fh, indent=4)
    if ARGUMENTS.verbose:
        print("Completed writing cloud infrastructure details to: ",
              ARGUMENTS.remote_mount_def_path)
