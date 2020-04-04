package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAzureAKS(t *testing.T) {

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/aks",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"service_principal_id":     os.Getenv("ARM_CLIENT_ID"),
			"service_principal_secret": os.Getenv("ARM_CLIENT_SECRET"),
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

}
