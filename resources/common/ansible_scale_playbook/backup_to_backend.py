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


def aws_s3_upload_object(bucket_name, obj_name, file_path):
    """
        This function performs upload of file as s3 object.

        Args:
            bucket_name (str): Bucket name
            obj_name (str): Object name
            file_path (str): File path used for object upload
    """
    print("[CLOUD-DEPLOY] Uploading inventory (%s) to bucket (%s) as object "
          "(%s)." % (file_path, bucket_name, obj_name))
    aws_command = ["/usr/local/bin/aws", "s3", "cp", file_path,
                   "s3://%s/%s" % (bucket_name, obj_name)]
    out, err, code = local_execution(aws_command)
    if code:
        print("[CLOUD-DEPLOY] Error while uploading file (%s) to bucket (%s). "
              "Existing!" % (file_path, bucket_name))
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)
    else:
        print("[CLOUD-DEPLOY] Upload of file (%s) as object (%s) completed "
              "successfully." % (file_path, obj_name))


def gcp_gcs_upload_object(bucket_name, obj_name, file_path):
    """
        This function performs upload of file as GCS object.

        Args:
            bucket_name (str): Bucket name
            obj_name (str): Object name
            file_path (str): File path used for object upload
    """
    print("[CLOUD-DEPLOY] Uploading inventory (%s) to bucket (%s) as object "
          "(%s)." % (file_path, bucket_name, obj_name))
    aws_command = ["/usr/local/bin/gsutil", "cp", file_path,
                   "gs://%s/%s" % (bucket_name, obj_name)]
    out, err, code = local_execution(aws_command)
    if code:
        print("[CLOUD-DEPLOY] Error while uploading file (%s) to bucket (%s). "
              "Existing!" % (file_path, bucket_name))
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)
    else:
        print("[CLOUD-DEPLOY] Upload of file (%s) as object (%s) completed "
              "successfully." % (file_path, obj_name))


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Backup local file to '
                                                 'specified backend.')
    PARSER.add_argument('--cloud_platform', required=True,
                        help='Cloud platform')
    PARSER.add_argument('--local_file_path', required=True,
                        help='Local file absolute path to back up')
    PARSER.add_argument('--bucket_name', required=True,
                        help='Bucket name')
    PARSER.add_argument('--obj_name', required=True,
                        help='Object name')
    PARSER.add_argument('--verbose', action='store_true',
                        help='print log messages')
    ARGUMENTS = PARSER.parse_args()

    if ARGUMENTS.cloud_platform.upper() == 'AWS':
        aws_s3_upload_object(ARGUMENTS.bucket_name,
                             ARGUMENTS.obj_name,
                             ARGUMENTS.local_file_path)
    elif ARGUMENTS.cloud_platform.upper() == 'GCP':
        gcp_gcs_upload_object(ARGUMENTS.bucket_name,
                              ARGUMENTS.obj_name,
                              ARGUMENTS.local_file_path)
