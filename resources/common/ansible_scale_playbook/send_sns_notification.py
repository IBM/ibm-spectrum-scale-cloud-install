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

# Note: Use cloud_platform flag to alter the send notification api per cloud.

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


def aws_send_sns_notification(region_name, message, topic_arn):
    """
    Sends a message to an Amazon SNS topic.
    :args: region_name(str), message(str), topic_arn(str)
    """
    print("[CLOUD-DEPLOY] Sending message (%s) to SNS topic (%s)." % (message, topic_arn))
    aws_command = ["/usr/local/bin/aws", "sns", "publish", "--topic-arn", topic_arn,
                   "--region", region_name, "--message", message]
    out, err, code = local_execution(aws_command)
    if code:
        print("[CLOUD-DEPLOY] Sending message (%s) to SNS topic (%s) failed. Existing!"
              % (message, topic_arn))
        print("%s: %s %s: %s" % ("stdout", out, "stderr", err))
        sys.exit(1)
    else:
        print("[CLOUD-DEPLOY] Sending message (%s) to SNS topic (%s) completed successfully."
              % (message, topic_arn))


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Publish message to SNS ARN.')
    PARSER.add_argument('--message', required=True,
                        help='Message to be notified')
    PARSER.add_argument('--topic_arn', required=True,
                        help='Topic ARN to publish message')
    PARSER.add_argument('--region_name', required=True,
                        help='Region name')
    ARGUMENTS = PARSER.parse_args()

    aws_send_sns_notification(ARGUMENTS.region_name,
                              ARGUMENTS.message,
                              ARGUMENTS.topic_arn)
