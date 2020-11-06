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
import re
from string import Template


def write_jumphost_template(ssh_config_path):
    """ Write jump host ssh config file """
    with open(ssh_config_path, 'w') as file_handler:
        file_handler.write(RAW_SSH_CONFIG.substitute(**JUMP_CONTEXT))


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Generate jump host SSH config.')
    PARSER.add_argument('--bastion_public_ip', required=True,
                        help='Bastion public ip address')
    PARSER.add_argument('--instances_ssh_private_key_path', required=True,
                        help='SSH key path (Ex: /root/.ssh/id_rsa)')
    PARSER.add_argument('--instances_ssh_user_name', required=True,
                        help='Instances SSH username')
    PARSER.add_argument('--instances_private_subnet_cidr', required=True,
                        help='Instances private subnet')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    RESULT = re.match(r"(\d+).(\d+).*", ARGUMENTS.instances_private_subnet_cidr)
    INSTANCES_PRIVATE_SUBNET = RESULT.group(1) + '.' + RESULT.group(2) + '.' + '*' + '.' + '*'

    RAW_SSH_CONFIG = Template("""Host ${bastion_public_ip}
  IdentityFile ${instances_ssh_private_key_path}
  User ${instances_ssh_user_name}
  StrictHostKeyChecking no
  CheckHostIP no
  ForwardAgent yes

# Specify the private subnet ip range
Host ${instances_private_subnet}
  IdentityFile ${instances_ssh_private_key_path}
  User ${instances_ssh_user_name}
  StrictHostKeyChecking no
  ProxyCommand ssh -W %h:%p ${instances_ssh_user_name}@${bastion_public_ip}
    """)
    JUMP_CONTEXT = {"bastion_public_ip": ARGUMENTS.bastion_public_ip,
                    "instances_ssh_private_key_path": ARGUMENTS.instances_ssh_private_key_path,
                    "instances_ssh_user_name": ARGUMENTS.instances_ssh_user_name,
                    "instances_private_subnet": INSTANCES_PRIVATE_SUBNET}

    if ARGUMENTS.verbose:
        print("Generated SSH tunnel settings:")
        print(RAW_SSH_CONFIG.substitute(**JUMP_CONTEXT))

    write_jumphost_template("/root/.ssh/config")
