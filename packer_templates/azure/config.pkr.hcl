packer {
  required_plugins {
    azure = {
      version = "~> 2"
      source  = "github.com/hashicorp/azure"
    }
  }
}
