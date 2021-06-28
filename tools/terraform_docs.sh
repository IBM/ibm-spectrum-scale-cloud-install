#!/usr/bin/env bash

echo "Generating terraform-docs"
root_dir=$(git rev-parse --show-toplevel)
terraform-docs $root_dir/aws_scale_templates/aws_new_vpc_scale
terraform-docs $root_dir/aws_scale_templates/prepare_tf_s3_backend
terraform-docs $root_dir/aws_scale_templates/sub_modules/vpc_template
terraform-docs $root_dir/aws_scale_templates/sub_modules/bastion_template
terraform-docs $root_dir/aws_scale_templates/sub_modules/instance_template
