#!/usr/bin/env python3

import yaml
import json
import argparse


ANSIBLE_HOSTS_PATH = "hosts"
ANSIBLE_GROUP_VARS_PATH = "all.yml"

def read_tf_inv_file(tf_inv_path):
    """ Read the terraform inventory file """
    tf_inv_list = open(tf_inv_path).read().splitlines()
    return tf_inv_list

if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Convert terraform inventory '
                                                 'to ansible inventory format '
                                                 'required for Spectrum Scale '
                                                 'install and configuration.')
    PARSER.add_argument('--tf_inv_path', required=True,
                        help='Terraform inventory file path')
    ARGUMENTS = PARSER.parse_args()

print(read_tf_inv_file(ARGUMENTS.tf_inv_path))
