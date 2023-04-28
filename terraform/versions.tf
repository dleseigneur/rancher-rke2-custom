terraform {
	required_version = ">= 1.0.7"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 1.24.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    template = {
      source = "hashicorp/template"
      version = ">=2.2.0"
    }
  }
}
