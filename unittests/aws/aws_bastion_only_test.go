package test

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAwsBastionOnly(t *testing.T) {
	logger.Log(t, "Testcase-1: Create a new vpc with 3AZs and provision bastion")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
	vpcterraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
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

	defer terraform.Destroy(t, vpcterraformOptions)

	terraform.InitAndApply(t, vpcterraformOptions)

	vpcID := terraform.Output(t, vpcterraformOptions, "vpc_id")
	vpcPublicSubnets := terraform.OutputList(t, vpcterraformOptions, "vpc_public_subnets")

	keyPair := aws.CreateAndImportEC2KeyPair(t, region, expectedName)
	testdir, testdirerr := os.Getwd()
	if testdirerr != nil {
		panic(testdirerr)
	}

	privateKeyPath := path.Join(testdir, expectedName)
	err := ioutil.WriteFile(privateKeyPath, []byte(keyPair.PrivateKey), 0600)
	if err != nil {
		panic(err)
	}

	log.Printf("Key saved to: %s", privateKeyPath)

	bastionterraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/bastion_template",

		Vars: map[string]interface{}{
			"vpc_region":                     region,
			"vpc_id":                         vpcID,
			"resource_prefix":                expectedName,
			"bastion_public_ssh_port":        22,
			"remote_cidr_blocks":             []string{"0.0.0.0/0"},
			"bastion_ami_name":               "Amazon-Linux2-HVM",
			"bastion_instance_type":          "t2.micro",
			"bastion_key_pair":               keyPair.Name,
			"vpc_auto_scaling_group_subnets": vpcPublicSubnets,
		},
	})

	defer terraform.Destroy(t, bastionterraformOptions)
	aws.DeleteEC2KeyPair(t, keyPair)

	terraform.InitAndApply(t, bastionterraformOptions)

	actualBastionPrivateIP := terraform.OutputList(t, bastionterraformOptions, "bastion_instance_private_ip")
	actualBastionPublicIP := terraform.OutputList(t, bastionterraformOptions, "bastion_instance_public_ip")
	actualBastionSecuritygrpID := terraform.Output(t, bastionterraformOptions, "bastion_security_group_id")

	assert.Equal(t, 1, len(actualBastionPrivateIP))
	assert.Equal(t, 1, len(actualBastionPublicIP))
	assert.Contains(t, actualBastionSecuritygrpID, "sg-")

	keyerr := os.Remove(privateKeyPath)
	if keyerr != nil {
		panic(keyerr)
	}
}
