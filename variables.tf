# Org-specific values (vm_name, node) have NO defaults — they must be supplied by
# the caller. Generic Proxmox conventions (bridge, datastore) carry safe defaults.

variable "vm_name" {
  description = "Name of the VM to create."
  type        = string
}

variable "node" {
  description = "Proxmox node to create the VM on."
  type        = string
}

variable "template_name" {
  description = "Template name to clone (looked up on `node`). Matches packer-template-proxmox output."
  type        = string
  default     = "ubuntu-24.04-template"
}

variable "vm_id" {
  description = "Explicit VMID for the new VM. Auto-assigned by Proxmox if null."
  type        = number
  default     = null
}

variable "cores" {
  description = "Number of vCPU cores."
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets."
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "CPU type. 'x86-64-v2-AES' is migratable; 'host' is fastest but pins to the node CPU."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Primary disk size in GiB. Must be >= the template's disk size."
  type        = number
  default     = 20
}


variable "datastore_id" {
  description = "Datastore for the VM disk, EFI disk, and cloud-init drive."
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Bridge for the primary network interface."
  type        = string
  default     = "vmbr0"
}

variable "bios" {
  description = "Firmware: 'ovmf' (UEFI) or 'seabios'. Must match the template."
  type        = string
  default     = "ovmf"

  validation {
    condition     = contains(["ovmf", "seabios"], var.bios)
    error_message = "bios must be 'ovmf' or 'seabios'."
  }
}

variable "ci_user" {
  description = "cloud-init login user."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_keys" {
  description = "SSH public keys authorised for the cloud-init user."
  type        = list(string)
  default     = []
}

variable "ip_config" {
  description = "cloud-init IPv4 config. Use 'dhcp', or a CIDR like '192.0.2.10/24' with a gateway. nameserver is optional and defaults to the gateway when a static address is used."
  type = object({
    ipv4_address = optional(string, "dhcp")
    ipv4_gateway = optional(string, null)
    nameserver   = optional(string, null)
  })
  default = {}
}

variable "search_domain" {
  description = "DNS search domain for cloud-init (static addresses only). Org-specific; supplied by the caller. Omitted when null."
  type        = string
  default     = null
}

variable "tags" {
  description = "Proxmox tags applied to the VM."
  type        = list(string)
  default     = []
}


