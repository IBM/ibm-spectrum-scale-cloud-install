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

func TestAwsVpc1AzwhBastionMinimal(t *testing.T) {
	logger.Log(t, "Testcase-1: Create a Spectrum Scale cluster (remote mount) in a new vpc with 1AZ and provision bastion")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := aws.GetRandomStableRegion(t, nil, nil)
	azs := aws.GetAvailabilityZones(t, region)
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

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/aws_new_vpc_scale",

		Vars: map[string]interface{}{
			"vpc_region":                   region,
			"vpc_availability_zones":       azs[0],
			"resource_prefix":              "spectrum-scale",
			"bastion_key_pair":             keyPair.Name,
			"bastion_ssh_private_key":      privateKeyPath,
			"compute_cluster_key_pair":     keyPair.Name,
			"storage_cluster_key_pair":     keyPair.Name,
			"compute_cluster_ami_id":       "ami-0b0af3577fe5e3532",
			"compute_cluster_gui_username": "admin",
			"compute_cluster_gui_password": "Passw0rd",
			"storage_cluster_ami_id":       "ami-0b0af3577fe5e3532",
			"storage_cluster_gui_username": "admin",
			"storage_cluster_gui_password": "Passw0rd",
			"operator_email":               "sasikanth.eda@in.ibm.com",
			"scale_version":                "5.1.1.0",
		},
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)
	aws.DeleteEC2KeyPair(t, keyPair)

	actualBastionPrivateIP := terraform.OutputList(t, terraformOptions, "bastion_instance_private_ip")
	actualBastionPublicIP := terraform.OutputList(t, terraformOptions, "bastion_instance_public_ip")
	actualBastionSecuritygrpID := terraform.Output(t, terraformOptions, "bastion_security_group_id")

	actualVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	actualVpcPublicSubnets := terraform.OutputList(t, terraformOptions, "vpc_public_subnets")
	actualVpcStoragePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_storage_cluster_private_subnets")
	actualVpcComputePrivateSubnets := terraform.OutputList(t, terraformOptions, "vpc_compute_cluster_private_subnets")

	actualComputeClusterID := terraform.OutputList(t, terraformOptions, "compute_cluster_instance_ids")
	actualComputeClusterIP := terraform.OutputList(t, terraformOptions, "compute_cluster_instance_private_ips")
	actualStorageClusterDescID := terraform.OutputList(t, terraformOptions, "storage_cluster_desc_instance_ids")
	actualStorageClusterDescIP := terraform.OutputList(t, terraformOptions, "storage_cluster_desc_instance_private_ips")
	actualStorageClusterDescMap := terraform.OutputMap(t, terraformOptions, "storage_cluster_desc_data_volume_mapping")
	actualStorageClusterID := terraform.OutputList(t, terraformOptions, "storage_cluster_instance_ids")
	actualStorageClusterIP := terraform.OutputList(t, terraformOptions, "storage_cluster_instance_private_ips")
	actualStorageClusterMap := terraform.OutputMap(t, terraformOptions, "storage_cluster_with_data_volume_mapping")
	keys := make([]string, 0, len(actualStorageClusterMap))
	for k := range actualStorageClusterMap {
		keys = append(keys, k)
	}

	assert.Equal(t, 1, len(actualBastionPrivateIP))
	assert.Equal(t, 1, len(actualBastionPublicIP))
	assert.Contains(t, actualBastionSecuritygrpID, "sg-")

	assert.Contains(t, actualVpcID, "vpc-")
	assert.Equal(t, 1, len(actualVpcPublicSubnets))
	assert.Equal(t, 1, len(actualVpcStoragePrivateSubnets))
	assert.Equal(t, 1, len(actualVpcComputePrivateSubnets))

	assert.Equal(t, 3, len(actualComputeClusterID))
	assert.Equal(t, 3, len(actualComputeClusterIP))
	assert.Equal(t, 0, len(actualStorageClusterDescID))
	assert.Equal(t, 0, len(actualStorageClusterDescIP))
	assert.Equal(t, map[string]string{}, actualStorageClusterDescMap)
	assert.Equal(t, 4, len(actualStorageClusterID))
	assert.Equal(t, 4, len(actualStorageClusterIP))
	assert.Equal(t, 4, len(actualStorageClusterMap))
	assert.Equal(t, "[/dev/xvdf]", actualStorageClusterMap[keys[0]])
	assert.Equal(t, 1, len([]string{actualStorageClusterMap[keys[0]]}))
}
