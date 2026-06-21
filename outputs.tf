output "vm_id" {
  description = "VMID of the created VM."
  value       = proxmox_vm_qemu.this.vmid
}

output "name" {
  description = "Name of the created VM."
  value       = proxmox_vm_qemu.this.name
}

output "ipv4_address" {
  description = "IPv4 address of the created VM (as configured; static or DHCP)."
  value = (
    var.ip_config.ipv4_address == "dhcp"
    ? "dhcp (assigned by network)"
    : split("/", var.ip_config.ipv4_address)[0]
  )
}
