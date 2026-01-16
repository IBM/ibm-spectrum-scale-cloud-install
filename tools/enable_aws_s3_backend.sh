#!/usr/bin/env bash

prepare_tf_s3_backend() {
    echo "Setting up prerequisites for s3 backend."
    read -p "Enter s3 bucket name (recommended to use new): " bucket_name
    read -p "Enter dynamoDB table name (recommended to use new): " dynamodb_table_name
    read -p "Enter region where AWS operations have to take place: " vpc_region
    terraform -chdir=$root_dir/aws_scale_templates/prepare_tf_s3_backend/ init
    terraform -chdir=$root_dir/aws_scale_templates/prepare_tf_s3_backend/ apply -var="bucket_name=$bucket_name" -var="dynamodb_table_name=$dynamodb_table_name" -var="vpc_region=$vpc_region" --auto-approve
    return $?
}

root_dir=$(git rev-parse --show-toplevel)
PS3="Choose the deployment option for enabling s3 backend: "
deployment_variations=("New_vpc" "Existing_vpc" "Exit")

select choice in "${deployment_variations[@]}";
do
    case $choice in
        "New_vpc")
            prepare_tf_s3_backend
            echo "Adding terraform s3 backend configuration to \"aws new vpc provider\"."
            cat >> $root_dir/aws_scale_templates/aws_new_vpc_scale/providers.tf <<EOL

terraform {
   backend "s3" {
     bucket         = "$bucket_name"
     key            = "$vpc_region/s3/terraform.tfstate"
     region         = "$vpc_region"
     dynamodb_table = "$dynamodb_table_name"
   }
}
EOL
        echo "Adding terraform s3 backend configuration to \"aws new vpc provider\" completed successfully."
        exit
        ;;

        "Existing_vpc")
            prepare_tf_s3_backend
            echo "Adding terraform s3 backend configuration to \"aws existing vpc provider\"."
            cat >> $root_dir/aws_scale_templates/sub_modules/instance_template/providers.tf <<EOL

terraform {
   backend "s3" {
     bucket         = "$bucket_name"
     key            = "$vpc_region/s3/terraform.tfstate"
     region         = "$vpc_region"
     dynamodb_table = "$dynamodb_table_name"
   }
}
EOL
        echo "Adding terraform s3 backend configuration to \"aws existing vpc provider\" completed successfully."
        exit
        ;;

        "Exit")
            echo "Exiting!"
            exit
            ;;
        *) echo "Invalid option. Exit!"
            ;;
    esac
done
