terraform {
  # Permissive lower bound for a reusable module; consumers pin exact versions.
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}
