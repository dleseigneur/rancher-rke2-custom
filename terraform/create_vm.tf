
data "vsphere_datacenter" "dc" {
    name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastores" {
    for_each = var.vm-datastore
    name = each.value
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "clusters" {
    for_each = var.vsphere-cluster
    name = each.value
    datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_distributed_virtual_switch" "dvs" {
  for_each = var.dvs
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networks" {
    for_each = var.dvs
    name = var.vm-network
    datacenter_id = data.vsphere_datacenter.dc.id
    distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs[each.key].id
}

data "vsphere_virtual_machine" "template" {
    name = var.vm-template-name
    datacenter_id = data.vsphere_datacenter.dc.id
}

# Create VM Folder
 resource "vsphere_folder" "folder" {
   path          = var.rancher2_nom_cluster
   type          = "vm"
   datacenter_id = data.vsphere_datacenter.dc.id
 }


resource "random_id" "vm_suffixe" {
 byte_length = 3
}

// # Create Control VMs AZ
resource "vsphere_virtual_machine" "masters" {
    for_each = var.vsphere-cluster
    name = "${var.vm-prefix-master}-${each.key}-1-${random_id.vm_suffixe.hex}"
    resource_pool_id = data.vsphere_compute_cluster.clusters[each.key].resource_pool_id
    datastore_id = data.vsphere_datastore.datastores[each.key].id
    folder = vsphere_folder.folder.path
    num_cpus = var.vm-cpu-master
    memory = var.vm-ram-master
    guest_id = var.vm-guest-id
    enable_disk_uuid = true
    network_interface {
        network_id = data.vsphere_network.networks[each.key].id
    }
    
    dynamic "disk" {
      for_each = data.vsphere_virtual_machine.template.disks
    
      content {
       label       = "disk${disk.value.unit_number}"
       unit_number = disk.value.unit_number
       # Si 3eme disque alors on utilise la taille definie dans le tfvars
       size        =  disk.value.unit_number == 2 ? var.vm-disk-data-size : disk.value.size
       eagerly_scrub    = disk.value.eagerly_scrub
       thin_provisioned = disk.value.thin_provisioned
      }
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
          timeout = 0
          linux_options {
            host_name = "${var.vm-prefix-master}-${each.key}-1-${random_id.vm_suffixe.hex}"
            domain = var.vm-domain-name
          }
          network_interface {}
          #   # DHCP
          #   dns_server_list = var.vm-dns-servers
          #   dns_suffix_list = var.vm-dns-search
        }
    }
    cdrom {
      client_device = true
    }
    provisioner "remote-exec" {
      inline = [
        "update-ca-certificates",
        local.enregistre_node_master
      ]
      connection {
        type = "ssh"
        user = "root"
        host = self.default_ip_address
        private_key = file("./keys/rkeid_rsa")
      }
    }
    lifecycle {
      ignore_changes = [ annotation, tags, datastore_id, disk ]
}
  depends_on = [
    vsphere_folder.folder
  ]
}

# transforme le dictionnaire [ az1 = 2 ] en ([ az1-1 = az1 ], [ az1-2 = az1 ])
# pour etre accepté par for_each
locals {
  count-vm = transpose({
    for az, nombre in var.worker-count : az  => [
      for n in range(nombre) : "${az}-${n + 1}"
    ]
  })
}


resource "vsphere_virtual_machine" "workers" {
    for_each = local.count-vm

    name = "${var.vm-prefix-worker}-${each.key}-${random_id.vm_suffixe.hex}"
    resource_pool_id = data.vsphere_compute_cluster.clusters[join("",each.value)].resource_pool_id
    datastore_id = data.vsphere_datastore.datastores[join("",each.value)].id
    folder = vsphere_folder.folder.path
    num_cpus = var.vm-cpu-worker
    memory = var.vm-ram-worker
    guest_id = var.vm-guest-id
    enable_disk_uuid = true
    network_interface {
        network_id = data.vsphere_network.networks[join("",each.value)].id
    }
    
    dynamic "disk" {
      for_each = data.vsphere_virtual_machine.template.disks
    
      content {
       label       = "disk${disk.value.unit_number}"
       unit_number = disk.value.unit_number
       # Si 3eme disque alors on utilise la taille definie dans le tfvars
       size        =  disk.value.unit_number == 2 ? var.vm-disk-data-size : disk.value.size
       eagerly_scrub    = disk.value.eagerly_scrub
       thin_provisioned = disk.value.thin_provisioned
      }
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
          timeout = 0
          linux_options {
            host_name = "${var.vm-prefix-worker}-${each.key}-${random_id.vm_suffixe.hex}"
            domain = var.vm-domain-name
          }
          network_interface {}
          #   # DHCP
          #   dns_server_list = var.vm-dns-servers
          #   dns_suffix_list = var.vm-dns-search
        }
    }
    cdrom {
      client_device = true
    }
    provisioner "remote-exec" {
      inline = [
        "update-ca-certificates",
        local.enregistre_node_worker
      ]
      connection {
        type = "ssh"
        user = "root"
        host = self.default_ip_address
        private_key = file("./keys/rkeid_rsa")
      }
    }
    lifecycle {
      ignore_changes = [ annotation, tags, datastore_id, disk ]
}

}



