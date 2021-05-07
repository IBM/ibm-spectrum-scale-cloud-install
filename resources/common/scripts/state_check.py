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
import sys

if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description='Validate resource state '
                                                 'status.')
    PARSER.add_argument('--resource_name', required=True,
                        help='Resource name.')
    PARSER.add_argument('--resource_id', required=True,
                        help='Resource id.')
    ARGUMENTS = PARSER.parse_args()

    if ARGUMENTS.resource_id == "False":
        print("Provided value to variable \"var.%s\" does not exist. Existing!" % ARGUMENTS.resource_name)
        sys.exit(255)
