package test

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	terraaws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAwsVpc1AzStorage2diskOnly(t *testing.T) {
	logger.Log(t, "Testcase-1: Create a Spectrum Scale storage cluster with dual disks in a new vpc with 1AZ")
	expectedName := fmt.Sprintf("spectrum-scale-%s", strings.ToLower(random.UniqueId()))
	region := terraaws.GetRandomStableRegion(t, nil, nil)
	azs := terraaws.GetAvailabilityZones(t, region)
	keyPair := terraaws.CreateAndImportEC2KeyPair(t, region, expectedName)
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

	rhelownerID := "309956199498"
	rhelImageSearch := "RHEL-8.4.0_HVM-*x86_64-*-Hourly2-GP2"

	session, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		panic(err)
	}

	svc := ec2.New(session)
	input := &ec2.DescribeImagesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("name"),
				Values: []*string{aws.String(rhelImageSearch)},
			},
			{
				Name:   aws.String("state"),
				Values: []*string{aws.String("available")},
			},
			{
				Name:   aws.String("virtualization-type"),
				Values: []*string{aws.String("hvm")},
			},
		},
		Owners: []*string{aws.String(rhelownerID)},
	}

	result, err := svc.DescribeImages(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			fmt.Println(err.Error())
		}
		return
	}

	log.Printf("Identified image id: %s", aws.StringValue(result.Images[0].ImageId))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/aws_new_vpc_scale",

		Vars: map[string]interface{}{
			"vpc_region":                             region,
			"vpc_availability_zones":                 []string{azs[0]},
			"resource_prefix":                        "spectrum-scale",
			"bastion_key_pair":                       keyPair.Name,
			"bastion_ssh_private_key":                privateKeyPath,
			"compute_cluster_key_pair":               keyPair.Name,
			"storage_cluster_key_pair":               keyPair.Name,
			"compute_cluster_image_id":               aws.StringValue(result.Images[0].ImageId),
			"compute_cluster_gui_username":           "admin",
			"compute_cluster_gui_password":           "Passw0rd",
			"total_compute_cluster_instances":        0,
			"ebs_block_devices_per_storage_instance": 2,
			"storage_cluster_image_id":               aws.StringValue(result.Images[0].ImageId),
			"storage_cluster_gui_username":           "admin",
			"storage_cluster_gui_password":           "Passw0rd",
			"operator_email":                         "sasikanth.eda@in.ibm.com",
			"scale_version":                          "5.1.1.0",
		},
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)
	terraaws.DeleteEC2KeyPair(t, keyPair)
	keyerr := os.Remove(privateKeyPath)
	if keyerr != nil {
		panic(keyerr)
	}

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

	assert.Equal(t, 0, len(actualComputeClusterID))
	assert.Equal(t, 0, len(actualComputeClusterIP))
	assert.Equal(t, 0, len(actualStorageClusterDescID))
	assert.Equal(t, 0, len(actualStorageClusterDescIP))
	assert.Equal(t, map[string]string{}, actualStorageClusterDescMap)
	assert.Equal(t, 4, len(actualStorageClusterID))
	assert.Equal(t, 4, len(actualStorageClusterIP))
	assert.Equal(t, 4, len(actualStorageClusterMap))
	assert.Equal(t, "[/dev/xvdf]", actualStorageClusterMap[keys[0]])
	assert.Equal(t, 1, len([]string{actualStorageClusterMap[keys[0]]}))
}
