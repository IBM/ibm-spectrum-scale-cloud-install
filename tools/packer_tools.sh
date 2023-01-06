#!/usr/bin/env bash

echo "Performing packer fmt, validation"
root_dir=$(git rev-parse --show-toplevel)
packer fmt $root_dir/packer_templates/aws
packer fmt $root_dir/packer_templates/azure
packer fmt $root_dir/packer_templates/ibmcloud
packer fmt $root_dir/packer_templates/gcp
