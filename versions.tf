terraform {
  # Permissive lower bound for a reusable module; consumers pin exact versions.
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # 3.0.1-rc3 checks for the Proxmox privilege "VM.Monitor" on every
      # plan/apply for any proxmox_vm_qemu resource. Proxmox VE 9.x removed
      # that privilege (replaced by granular VM.GuestAgent.* privileges) but
      # the provider's guest-agent endpoint check wasn't updated to match,
      # so no role — including a full Administrator grant — can satisfy it.
      # Fixed upstream in Telmate/terraform-provider-proxmox#1382, first
      # released in 3.0.2-rc04. This pin (3.0.2-rc07) is the latest available
      # release carrying that fix; it also requires two schema migrations in
      # this file: "cpu" (string) -> "cpu_type", and network blocks now
      # require an explicit "id".
      version = "3.0.2-rc07"
    }
  }
}
