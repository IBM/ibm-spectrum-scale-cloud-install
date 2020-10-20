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
import subprocess
import sys
import time

# Note: Use cloud_platform flag to alter the backend api per cloud.


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

def aws_ssm_put_parameter(param_name, local_file_path, param_type, region_name):
    """
        This function performs SSM put-parameter operation.

        Args:
            param_name (str): SSM parameter name
            local_file_path (str): Local file path used for reading secrets
            param_type (str): SSM parameter type
            region_name (str): Region of operation
    """
    param_value, max_retry, retry_count, code = None, 3, 0, 1
    with open(local_file_path, 'r') as secret_file:
        param_value = secret_file.read()

    if ARGUMENTS.verbose:
        print("[CLOUD-DEPLOY] Uploading parameter value (%s)." % (param_value))

    while (code and retry_count < max_retry):
        print("[CLOUD-DEPLOY] Uploading secret (%s) as parameter (%s)."
              % (local_file_path, param_name))
        aws_command = ["/usr/local/bin/aws", "ssm", "put-parameter", "--name",
                       param_name, "--value", param_value, "--type",
                       param_type, "--overwrite", "--region", region_name]
        out, err, code = local_execution(aws_command)
        retry_count += 1
        time.sleep(30)

    if code:
        print("[CLOUD-DEPLOY] Error while uploading secret (%s) as parameter (%s). "
              "Existing!" % (local_file_path, param_name))
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)
    else:
        print("[CLOUD-DEPLOY] Upload of secret (%s) as parameter (%s) completed "
              "successfully." % (local_file_path, param_name))


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Store values to secure '
                                                 'store.')
    PARSER.add_argument('--cloud_platform', required=True,
                        help='Cloud platform')
    PARSER.add_argument('--local_file_path', required=True,
                        help='Local file absolute path')
    PARSER.add_argument('--param_name', required=True,
                        help='SSM parameter name')
    PARSER.add_argument('--param_type', required=True,
                        help='SSM parameter type')
    PARSER.add_argument('--region_name', required=True,
                        help='Cloud operating region')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    if ARGUMENTS.cloud_platform.upper() == 'AWS':
        aws_ssm_put_parameter(ARGUMENTS.param_name,
                              ARGUMENTS.local_file_path,
                              ARGUMENTS.param_type,
                              ARGUMENTS.region_name)
