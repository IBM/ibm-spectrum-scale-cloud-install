#!/usr/bin/env bash

echo "Generating terraform-docs"
root_dir=$(git rev-parse --show-toplevel)
terraform-docs markdown $root_dir/aws_scale_templates/aws_new_vpc_scale --hide modules --hide providers --hide resources --output-file $root_dir/aws_scale_templates/aws_new_vpc_scale/README.md
terraform-docs markdown $root_dir/aws_scale_templates/sub_modules/vpc_template --hide modules --hide providers --hide resources --output-file $root_dir/aws_scale_templates/sub_modules/vpc_template/README.md
terraform-docs markdown $root_dir/aws_scale_templates/sub_modules/bastion_template --hide modules --hide providers --hide resources --output-file $root_dir/aws_scale_templates/sub_modules/bastion_template/README.md
terraform-docs markdown $root_dir/aws_scale_templates/sub_modules/instance_template --hide modules --hide providers --hide resources --output-file $root_dir/aws_scale_templates/sub_modules/instance_template/README.md
