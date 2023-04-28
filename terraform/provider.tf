# Configure the Rancher2 provider to admin
provider "rancher2" {
    api_url    = var.rancher2_api_url
    access_key = var.rancher2_access_key
    secret_key = var.rancher2_secret_key
#    token_key = var.rancher2_token_key
    insecure = true
}

# vsphere
provider "vsphere" {
    user           = var.vsphere-user
    password       = var.vsphere-password
    vsphere_server = var.vsphere-vcenter

    # If you have a self-signed cert
    allow_unverified_ssl = true
}