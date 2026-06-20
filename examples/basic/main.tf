# Minimal caller for `terraform validate`. Placeholder values only — no real
# org/host/credentials. Provider credentials come from the environment
# (PROXMOX_VE_ENDPOINT / PROXMOX_VE_USERNAME / PROXMOX_VE_PASSWORD).

terraform {
  required_version = ">= 1.9"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.0"
    }
  }
}

provider "proxmox" {
  # endpoint/username/password sourced from PROXMOX_VE_* environment variables.
  insecure = true
}

module "vm" {
  source = "../../"

  vm_name        = "example-vm"
  node           = "your-node"
  template_name  = "ubuntu-24.04-template"
  cores          = 2
  memory         = 2048
  disk_size      = 20
  network_bridge = "vmbr0"
  ci_user        = "ubuntu"
  ip_config      = { ipv4_address = "dhcp" }
  tags           = ["example"]
}

output "example_vm_ip" {
  value = module.vm.ipv4_address
}
