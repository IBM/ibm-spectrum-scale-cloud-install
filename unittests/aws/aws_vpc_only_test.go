package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAwsVpc3AzOnly(t *testing.T) {
	// The path to where our Terraform code is located
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws_scale_templates/sub_modules/vpc_template",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"vpc_region":             "us-east-1",
			"vpc_availability_zones": []string{"us-east-1a", "us-east-1b", "us-east-1c"},
		},
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)
}
