#!/usr/bin/env bash

root_dir=$(git rev-parse --show-toplevel)

echo "Generating AWS terraform-docs"
terraform-docs $root_dir/aws_scale_templates/aws_new_vpc_scale
terraform-docs $root_dir/aws_scale_templates/prepare_tf_s3_backend
terraform-docs $root_dir/aws_scale_templates/sub_modules/vpc_template
terraform-docs $root_dir/aws_scale_templates/sub_modules/bastion_template
terraform-docs $root_dir/aws_scale_templates/sub_modules/instance_template
echo "Generating Azue terraform-docs"
terraform-docs $root_dir/azure_scale_templates/sub_modules/vnet_template
terraform-docs $root_dir/azure_scale_templates/sub_modules/bastion_template
