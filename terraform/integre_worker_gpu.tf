
resource "null_resource" "machines_provisioner" {
  for_each = { for v in var.machines_GPU : v => v }
  connection {
    type  = "ssh"
    host  = each.key
    user  = "root"
    private_key = file("keys/rkeid_rsa")
  }
  provisioner "file" {
    source = "./config-machines-GPU"
    destination = "/tmp/config-machines-GPU"
   }
  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "update-ca-certificates",
      "${local.enregistre_node_worker} ${var.machine_physique_extralabel}",
      "sh /tmp/config-machines-GPU/configure-containerd-nvidia.sh"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sh /tmp/config-machines-GPU/machine-cleanup.sh"
    ]
  }
  depends_on = [
    vsphere_virtual_machine.masters["az1"]
  ]
}
