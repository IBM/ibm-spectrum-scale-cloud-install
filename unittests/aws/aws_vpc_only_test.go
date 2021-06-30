package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAwsVpc3AzCreateSubnetsOnly(t *testing.T) {
	logger.Log(t, "Testcase-1: Create a new vpc with 3AZs and seperate subnet for compute, storage clusters")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/vpc_template",

		Vars: map[string]interface{}{
			"vpc_region":                     region,
			"vpc_availability_zones":         azs[0:3],
			"resource_prefix":                expectedName,
			"vpc_cidr_block":                 "10.0.0.0/16",
			"vpc_public_subnets_cidr_blocks": []string{"10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"},
			"vpc_storage_cluster_private_subnets_cidr_blocks": []string{"10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"},
			"vpc_compute_cluster_private_subnets_cidr_blocks": []string{"10.0.7.0/24"},
			"vpc_create_separate_subnets":                     true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	actualVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	actualVpcInternetgw := terraform.Output(t, terraformOptions, "vpc_internet_gateway")
	actualVpcPublicSubnets := terraform.OutputList(t, terraformOptions, "vpc_public_subnets")
	actualVpcStoragePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_storage_cluster_private_subnets")
	actualVpcComputePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_compute_cluster_private_subnets")
	actualVpcNatgateways := terraform.OutputList(t, terraformOptions, "vpc_nat_gateways")

	assert.Contains(t, actualVpcID, "vpc-")
	assert.Contains(t, actualVpcInternetgw, "igw-")
	assert.Equal(t, 3, len(actualVpcPublicSubnets))
	assert.Equal(t, 3, len(actualVpcStoragePrivateSubnets))
	assert.Equal(t, 1, len(actualVpcComputePrivateSubnets))
	assert.Equal(t, 4, len(actualVpcNatgateways))
}

func TestAwsVpc3AzStorageSubnetsOnly(t *testing.T) {
	logger.Log(t, "Testcase-2: Create a new vpc with 3AZs and same subnet for compute, storage clusters")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/vpc_template",

		Vars: map[string]interface{}{
			"vpc_region":                     region,
			"vpc_availability_zones":         azs[0:3],
			"resource_prefix":                expectedName,
			"vpc_cidr_block":                 "10.0.0.0/16",
			"vpc_public_subnets_cidr_blocks": []string{"10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"},
			"vpc_storage_cluster_private_subnets_cidr_blocks": []string{"10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"},
			"vpc_compute_cluster_private_subnets_cidr_blocks": []string{"10.0.7.0/24"},
			"vpc_create_separate_subnets":                     false,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	actualVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	actualVpcInternetgw := terraform.Output(t, terraformOptions, "vpc_internet_gateway")
	actualVpcPublicSubnets := terraform.OutputList(t, terraformOptions, "vpc_public_subnets")
	actualVpcStoragePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_storage_cluster_private_subnets")
	actualVpcComputePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_compute_cluster_private_subnets")
	actualVpcNatgateways := terraform.OutputList(t, terraformOptions, "vpc_nat_gateways")

	assert.Contains(t, actualVpcID, "vpc-")
	assert.Contains(t, actualVpcInternetgw, "igw-")
	assert.Equal(t, 3, len(actualVpcPublicSubnets))
	assert.Equal(t, 3, len(actualVpcStoragePrivateSubnets))
	assert.Equal(t, 0, len(actualVpcComputePrivateSubnets))
	assert.Equal(t, 3, len(actualVpcNatgateways))
}

func TestAwsVpc1AzCreateSubnetsOnly(t *testing.T) {
	logger.Log(t, "Testcase-3: Create a new vpc with 1AZ and seperate subnet for compute, storage clusters")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/vpc_template",

		Vars: map[string]interface{}{
			"vpc_region":                     region,
			"vpc_availability_zones":         azs[0],
			"resource_prefix":                expectedName,
			"vpc_cidr_block":                 "10.0.0.0/16",
			"vpc_public_subnets_cidr_blocks": []string{"10.0.1.0/24"},
			"vpc_storage_cluster_private_subnets_cidr_blocks": []string{"10.0.4.0/24"},
			"vpc_compute_cluster_private_subnets_cidr_blocks": []string{"10.0.7.0/24"},
			"vpc_create_separate_subnets":                     true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	actualVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	actualVpcInternetgw := terraform.Output(t, terraformOptions, "vpc_internet_gateway")
	actualVpcPublicSubnets := terraform.OutputList(t, terraformOptions, "vpc_public_subnets")
	actualVpcStoragePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_storage_cluster_private_subnets")
	actualVpcComputePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_compute_cluster_private_subnets")
	actualVpcNatgateways := terraform.OutputList(t, terraformOptions, "vpc_nat_gateways")

	assert.Contains(t, actualVpcID, "vpc-")
	assert.Contains(t, actualVpcInternetgw, "igw-")
	assert.Equal(t, 1, len(actualVpcPublicSubnets))
	assert.Equal(t, 1, len(actualVpcStoragePrivateSubnets))
	assert.Equal(t, 1, len(actualVpcComputePrivateSubnets))
	assert.Equal(t, 2, len(actualVpcNatgateways))
}

func TestAwsVpc1AzStorageSubnetsOnly(t *testing.T) {
	logger.Log(t, "Testcase-4: Create a new vpc with 1AZ and same subnet for compute, storage clusters")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/vpc_template",

		Vars: map[string]interface{}{
			"vpc_region":                     region,
			"vpc_availability_zones":         azs[0],
			"resource_prefix":                expectedName,
			"vpc_cidr_block":                 "10.0.0.0/16",
			"vpc_public_subnets_cidr_blocks": []string{"10.0.1.0/24"},
			"vpc_storage_cluster_private_subnets_cidr_blocks": []string{"10.0.4.0/24"},
			"vpc_compute_cluster_private_subnets_cidr_blocks": []string{"10.0.7.0/24"},
			"vpc_create_separate_subnets":                     false,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	actualVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	actualVpcInternetgw := terraform.Output(t, terraformOptions, "vpc_internet_gateway")
	actualVpcPublicSubnets := terraform.OutputList(t, terraformOptions, "vpc_public_subnets")
	actualVpcStoragePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_storage_cluster_private_subnets")
	actualVpcComputePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_compute_cluster_private_subnets")
	actualVpcNatgateways := terraform.OutputList(t, terraformOptions, "vpc_nat_gateways")

	assert.Contains(t, actualVpcID, "vpc-")
	assert.Contains(t, actualVpcInternetgw, "igw-")
	assert.Equal(t, 1, len(actualVpcPublicSubnets))
	assert.Equal(t, 1, len(actualVpcStoragePrivateSubnets))
	assert.Equal(t, 0, len(actualVpcComputePrivateSubnets))
	assert.Equal(t, 1, len(actualVpcNatgateways))
}
