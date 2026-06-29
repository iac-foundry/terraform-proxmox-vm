# Proxmox VM clone using Telmate/proxmox provider.
# Clones a template, sets static IP via cloud-init, injects SSH keys.

resource "proxmox_vm_qemu" "this" {
  name           = var.vm_name
  target_node    = var.node
  vmid           = var.vm_id
  desc           = "Cloned from ${var.template_name}"
  clone          = var.template_name
  full_clone     = true
  onboot         = true
  agent          = 1
  # The IP this module reports (outputs.tf) comes entirely from the
  # ip_config input variable, never from a Terraform-computed, agent-derived
  # value — so the provider's automatic post-apply connection-info discovery
  # (which queries the QEMU guest agent's network-get-interfaces) is not
  # needed and is disabled here. That discovery call requires a privilege
  # historically named "VM.Monitor" in Proxmox's ACL model; on at least
  # Proxmox VE 9.2.3 this privilege does not appear in any role's granted
  # capability set (including a full Administrator/root@pam grant — verified
  # against the live API), so any module instance with agent = 1 and
  # define_connection_info left at its default (true) cannot complete an
  # apply on such hosts. agent stays enabled for genuine guest-agent service
  # features (graceful shutdown, fsfreeze, exec); only the connection-info
  # auto-discovery is turned off.
  define_connection_info = false
  numa           = true
  machine        = "q35"
  qemu_os        = "other"
  os_type        = "cloud-init"
  scsihw         = "virtio-scsi-pci"
  bios           = var.bios  # Force UEFI (ovmf) to match template
  cores          = var.cores
  sockets        = var.sockets
  cpu            = var.cpu_type
  memory         = var.memory

  # Storage: EFI and cloud-init disk
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.datastore_id
        }
      }
    }
    # Primary disk (resized from template)
    virtio {
      virtio0 {
        disk {
          size    = "${var.disk_size}G"
          storage = var.datastore_id
          format  = "raw"
        }
      }
    }
  }

  # Network
  network {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Cloud-init: user, SSH keys, optional password (handy for console debugging).
  ssh_user        = var.ci_user
  ssh_private_key = ""  # Not used; keys injected via cloud-init
  sshkeys         = join("\n", var.ssh_public_keys)
  cipassword      = var.ci_password

  # Static network via cloud-init. The clone's cloud-init drive carries this
  # config and cloud-init applies it on first boot — no post-creation SSH /
  # netplan provisioning needed. This requires the template's GRUB cmdline to
  # be free of `ip=dhcp` (see packer-template-proxmox sealing step); otherwise
  # the kernel cmdline network source overrides this. Mirrors the proven
  # homelab vm_network_docker pattern.
  ipconfig0 = var.ip_config.ipv4_address == "dhcp" ? "ip=dhcp" : "ip=${var.ip_config.ipv4_address},gw=${var.ip_config.ipv4_gateway}"

  # DHCP leases supply their own DNS; static configs set it explicitly.
  nameserver   = var.ip_config.ipv4_address == "dhcp" ? null : coalesce(var.ip_config.nameserver, var.ip_config.ipv4_gateway)
  searchdomain = var.ip_config.ipv4_address == "dhcp" ? null : var.search_domain
  skip_ipv6    = true

  # Tags for organization in Proxmox UI
  tags = join(";", var.tags)

  lifecycle {
    precondition {
      condition     = try(length(regexall("^${var.template_name}$", var.template_name)), 0) > 0
      error_message = "Template name '${var.template_name}' must be a valid name (will be looked up on the node)."
    }
  }
}

