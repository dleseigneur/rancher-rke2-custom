# Create a new rancher v2 RKE2 custom Cluster v2
resource "rancher2_cluster_v2" "moncluster" {
  name = var.rancher2_nom_cluster
  fleet_namespace = "fleet-default"
  kubernetes_version = var.rke2_kubernetes_version
  enable_network_policy = false
#  default_pod_security_policy_template_name = "unrestricted"
  default_cluster_role_for_project_members = "user"
  rke_config {
    upgrade_strategy {
      control_plane_concurrency = "10%"
      control_plane_drain_options {
        enabled = true
      }
      worker_concurrency = "10%"
      worker_drain_options {
        enabled = true
        delete_empty_dir_data = true
        disable_eviction = false
        force = false
        grace_period = 0
        ignore_daemon_sets = true
        ignore_errors = false
        skip_wait_for_delete_timeout_seconds = 0
        timeout = 5
      }
    }
    machine_global_config = var.custom_config
    registries {
      mirrors {
        hostname = "docker.io"
        endpoints = [ "https://docker.io" ]
      }
      mirrors {
        hostname = "k8s.gcr.io"
        endpoints = [ "https://k8s.gcr.io" ]
      }
      mirrors {
        hostname = "gcr.io"
        endpoints = [ "https://gcr.io" ]
      }
      mirrors {
        hostname = "ghcr.io"
        endpoints = [ "https://ghcr.io" ]
      }
      mirrors {
        hostname = "nvcr.io"
        endpoints = [ "https://nvcr.io" ]
      }
      mirrors {
        hostname = "quay.io"
        endpoints = [ "https://quay.io" ]
      }
      mirrors {
        hostname = "registry.k8s.io"
        endpoints = [ "https://registry.k8s.io" ]
      }
    }
    machine_selector_config {
      config = {
        system-default-registry = "docker-dev-virtual.repository.pole-emploi.intra",
        cloud-provider-name: "rancher-vsphere"
      }
    }
    chart_values = <<EOF
rke2-calico: {}
rancher-vsphere-cpi:
  vCenter:
    datacenters: ${var.vsphere-datacenter}
    host: ${var.vsphere-vcenter}
    password: ${var.vsphere-password}
    port: 443
    username: ${var.vsphere-user}
rancher-vsphere-csi:
  csiController:
    csiResizer:
      enabled: false
  storageClass:
    allowVolumeExpansion: true
    enabled: true
    isDefault: true
    name: sc-defaut-01
    storagePolicyName: rke2-storage-policy
  vCenter:
    datacenters: ${var.vsphere-datacenter}
    host: ${var.vsphere-vcenter}
    insecureFlag: '1'
    password: ${var.vsphere-password}
    port: 443
    username: ${var.vsphere-user}
EOF
  }
  
}

locals {
  enregistre_node_master = "${rancher2_cluster_v2.moncluster.cluster_registration_token.0.node_command} --etcd --controlplane"
  enregistre_node_worker = "${rancher2_cluster_v2.moncluster.cluster_registration_token.0.node_command} --worker"
}