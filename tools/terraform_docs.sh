#!/usr/bin/env bash

root_dir=$(git rev-parse --show-toplevel)

awsDocModules=(
    "$root_dir/aws_scale_templates/aws_new_vpc_scale"
    "$root_dir/aws_scale_templates/prepare_tf_s3_backend"
    "$root_dir/aws_scale_templates/sub_modules/vpc_template"
    "$root_dir/aws_scale_templates/sub_modules/bastion_template"
    "$root_dir/aws_scale_templates/sub_modules/dns_template"
    "$root_dir/aws_scale_templates/sub_modules/instance_template"
)

azureDocModules=(
    "$root_dir/azure_scale_templates/azure_new_vnet_scale"
    "$root_dir/azure_scale_templates/sub_modules/vpc_template"
    "$root_dir/azure_scale_templates/sub_modules/bastion_template"
    "$root_dir/azure_scale_templates/sub_modules/dns_template"
    "$root_dir/azure_scale_templates/sub_modules/instance_template"
)

ibmDocModules=(
    "$root_dir/ibmcloud_scale_templates/ibmcloud_new_vpc_scale"
    "$root_dir/ibmcloud_scale_templates/sub_modules/vpc_template"
    "$root_dir/ibmcloud_scale_templates/sub_modules/bastion_template"
    "$root_dir/ibmcloud_scale_templates/sub_modules/instance_template"
)

gcpDocModules=(
    "$root_dir/gcp_scale_templates/gcp_new_vpc_scale"
    "$root_dir/gcp_scale_templates/sub_modules/vpc_template"
    "$root_dir/gcp_scale_templates/sub_modules/bastion_template"
    "$root_dir/gcp_scale_templates/sub_modules/instance_template"
)

#Updates terraform docs if not already updated
updateTerraformDocs(){
    checkAndUpdateModules=("$@")
    for file in "${checkAndUpdateModules[@]}"
    do
        echo "Checking $file"
        var="$(terraform-docs $file --output-check)"

        if [[ $var =~ "up to date" ]]; then
            echo "Up-to-date"
        else
            terraform-docs $file
            git add $file
        fi
    done
}

echo "Generating AWS terraform-docs"
updateTerraformDocs "${awsDocModules[@]}"

echo "Generating Azure terraform-docs"
updateTerraformDocs "${azureDocModules[@]}"

echo "Generating IBM Cloud terraform-docs"
updateTerraformDocs "${ibmDocModules[@]}"

echo "Generating GCP Cloud terraform-docs"
updateTerraformDocs "${gcpDocModules[@]}"
