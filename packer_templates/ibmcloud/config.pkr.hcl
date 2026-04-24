packer {
  required_plugins {
    ibmcloud = {
      version = ">= v3.3.4"

      source = "github.com/IBM/ibmcloud"
    }
  }
}
