/*
 * RockyLinux OS 8 Packer template for building an Azure image.
 */

source "qemu" "rockylinux-8-azure-x86_64" {
  iso_url            = local.rocky_iso_url_8_x86_64
  iso_checksum       = local.rocky_checksum_8_x86_64
  shutdown_command   = var.root_shutdown_command
  accelerator        = "kvm"
  http_directory     = var.http_directory
  ssh_username       = var.gencloud_ssh_username
  ssh_password       = var.gencloud_ssh_password
  ssh_timeout        = var.ssh_timeout
  cpus               = var.cpus
  disk_interface     = "virtio-scsi"
  disk_size          = var.azure_disk_size
  disk_cache         = "unsafe"
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  format             = "raw"
  headless           = var.headless
  machine_type       = "q35"
  memory             = var.memory
  net_device         = "virtio-net"
  qemu_binary        = var.qemu_binary
  vm_name            = "RockyLinux-8-Azure-${var.os_ver_8}-${formatdate("YYYYMMDD", timestamp())}.x86_64.raw"
  boot_wait          = var.boot_wait
  boot_command       = local.rocky_azure_boot_command_8_x86_64
  qemuargs = [
    ["-cpu", "host"]
  ]
}

build {
  sources = ["qemu.rockylinux-8-azure-x86_64"]

  provisioner "ansible" {
    playbook_file    = "./ansible/azure.yml"
    galaxy_file      = "./ansible/requirements.yml"
    roles_path       = "./ansible/roles"
    collections_path = "./ansible/collections"
    galaxy_command   = "ansible-galaxy"
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes'",
      "ANSIBLE_GALAXY_SERVER=https://old-galaxy.ansible.com/"
    ]
  }

  provisioner "shell" {
    inline = ["dnf -y update"]
  }

  provisioner "shell" {
    environment_vars =  [
      "ARTIFACTORY_USERNAME=${var.ARTIFACTORY_USERNAME}",
      "ARTIFACTORY_PASSWORD=${var.ARTIFACTORY_PASSWORD}",
      "EDR_CCID=${var.EDR_CCID}",
      "EDR_TAGS=${var.EDR_TAGS}"
    ]
    script = "./scripts/run_imagefactory.sh"
  }

  provisioner "shell" {
    inline = ["sudo dracut -f -v", "sudo waagent -force -deprovision"]
  }

}
