# Connexion Rancher Manager
rancher2_api_url = "MY_RANCHER_URL"
rancher2_access_key = "MY_ACCESS_KEY"
rancher2_secret_key = "MY_SECRET_KEY"

# Cluster à traiter
rancher2_nom_cluster = "vsphere-ti"
rke2_kubernetes_version = "v1.23.8+rke2r1"
custom_config = <<EOF
cluster-cidr: MYRANGEIP1/16
cni: calico
disable:
- rke2-ingress-nginx
disable-kube-proxy: false
kube-proxy-arg:
- --proxy-mode=ipvs
- --ipvs-scheduler=lc
- --ipvs-strict-arp
etcd-expose-metrics: true
profile: null
service-cidr: MYRANGEIP2/16
service-node-port-range: 30000-35000
EOF

## Variables VMs
# terraform.tfvars

# We define how many master nodes
# we want to deploy for _each_ AZ
# master-count default value = 1
master-count = 1
# VM master
vm-prefix-master = "rke2-master"
vm-cpu-master = "2"
vm-ram-master = "8192"


# We define how many worker nodes
# we want to deploy for _each_ AZ
# worker-count default value = 1
# Attention, il faut définir la même
# valeur à toutes les AZ
worker-count = {
  az1 = "1"
  az2 = "1"
  az3 = "1"
}

# VM worker
vm-prefix-worker = "rke2-worker"
vm-cpu-worker = "4"
vm-ram-worker = "16384"

# Customisation US
vm-domain-name = "MYDOMAIN"
vm-disk-data-size = "250"

# VM Common Configuration
vm-template-name = "2022-12-14-tsles15"
#vm-template-name = "tsles15sp3-rke2-1.21.7"
vm-guest-id = "sles15_64Guest"
vm-network = "seg-applis-2600"
vm-domain = "rke2.local"
vm-dns-search = ["MYDOMAIN1", "MYDOMAIN2", "MYDOMAIN3"]
vm-dns-servers = ["MYIP1", "MYIP2"]

# vSphere configuration
vsphere-vcenter = "MYVCENTER"
vsphere-user = "MY_VSPHERE_USER"
vsphere-password = "MY_VSPHERE_PASSWORD"
vsphere-unverified-ssl = "true"
vsphere-datacenter = "TZ-SB-WLD01"
vsphere-cluster = {
  az1 = "CL_TZ_SB_WLD01_01"
  az2 = "CL_TZ_SB_WLD01_01"
  az3 = "CL_TZ_SB_WLD01_01"
}

vm-datastore = {
  az1 = "DS_TZ_SB_vSAN_WLD01_01"
  az2 = "DS_TZ_SB_vSAN_WLD01_01"
  az3 = "DS_TZ_SB_vSAN_WLD01_01"
}

dvs = {
  az1 = "DVS_TZ_SB_WLD01_02"
  az2 = "DVS_TZ_SB_WLD01_02"
  az3 = "DVS_TZ_SB_WLD01_02"
}

# Intégration de Machines physiques
machines_GPU = [
  "IP1_SERVERGPU",
  "IP2_SERVERGPU",
]