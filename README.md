# terraform-proxmox-vm

Org-neutral Terraform module that clones a Proxmox VM template (built by
`packer-template-proxmox`) into an addressable VM, injecting per-clone cloud-init
configuration (user, SSH keys, IP). Part of the iac-foundry framework.

This module is **generic**: it bakes in no organisation, hostnames, IPs, or secrets.
All of those are caller inputs. Concrete values live in the consuming repo (e.g. a
Vernify `terraform-<host>-deploy` repo), never here.

## What it does

- Looks up a template by **name** on a Proxmox node (default `ubuntu-24.04-template`,
  matching `packer-template-proxmox`) — or takes an explicit `template_vm_id`.
- Full-clones it into a new VM with the requested CPU / memory / disk size.
- Injects cloud-init: login user, SSH public keys, and DHCP or static IP.
- Enables the QEMU guest agent so the IP is discoverable, and exports it as an output.

The defaults match the Packer template's shape (UEFI/`ovmf`, primary disk on
`virtio0`). Override `bios` / `disk_interface` if you point this at a different template.

## Usage

```hcl
module "vm" {
  source = "github.com/iac-foundry/terraform-proxmox-vm?ref=v0.1.0"

  vm_name         = "dev01"
  node            = "pve"            # your Proxmox node
  template_name   = "ubuntu-24.04-template"
  cores           = 2
  memory          = 4096            # MiB
  disk_size       = 40             # GiB
  datastore_id    = "local-lvm"
  network_bridge  = "vmbr0"
  ci_user         = "ubuntu"
  ssh_public_keys = [file("~/.ssh/id_vernify_bootstrap.pub")]
  ip_config       = { ipv4_address = "dhcp" }
  tags            = ["vernify", "dev"]
}

output "dev01_ip" {
  value = module.vm.ipv4_address
}
```

Provider credentials are **not** module inputs. Configure the `bpg/proxmox` provider
in the root module, sourcing credentials from the environment (e.g. the bootstrap
container's `PROXMOX_*` variables → `PROXMOX_VE_ENDPOINT` / `PROXMOX_VE_USERNAME` /
`PROXMOX_VE_PASSWORD`).

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `vm_name` | string | — (required) | Name of the VM to create |
| `node` | string | — (required) | Proxmox node to create the VM on |
| `template_name` | string | `ubuntu-24.04-template` | Template name to clone (looked up on `node`) |
| `template_vm_id` | number | `null` | Explicit template VMID; skips the name lookup if set |
| `vm_id` | number | `null` | Explicit VMID for the new VM; auto-assigned if null |
| `cores` | number | `2` | vCPU cores |
| `sockets` | number | `1` | CPU sockets |
| `cpu_type` | string | `x86-64-v2-AES` | CPU type (use `host` for max perf, non-migratable) |
| `memory` | number | `2048` | Memory in MiB |
| `disk_size` | number | `20` | Primary disk size in GiB (must be ≥ template's disk) |
| `disk_interface` | string | `virtio0` | Primary disk interface (matches the Packer template) |
| `datastore_id` | string | `local-lvm` | Datastore for the VM disk and cloud-init drive |
| `network_bridge` | string | `vmbr0` | Bridge for the primary NIC |
| `bios` | string | `ovmf` | `ovmf` (UEFI) or `seabios`; must match the template |
| `ci_user` | string | `ubuntu` | cloud-init login user |
| `ssh_public_keys` | list(string) | `[]` | SSH public keys for the cloud-init user |
| `ip_config` | object | `{}` (DHCP) | `{ ipv4_address = "dhcp" or CIDR, ipv4_gateway = "..." }` |
| `tags` | list(string) | `[]` | Proxmox tags for the VM |

## Outputs

| Name | Description |
|---|---|
| `ipv4_address` | First non-loopback IPv4 address (via guest agent) |
| `vm_id` | VMID of the created VM |
| `name` | Name of the created VM |

## Testing

```bash
cd examples/basic
terraform init
terraform validate
```

A real `plan`/`apply` requires Proxmox API access and is exercised from a consuming
repo (e.g. via the Vernify bootstrap container) — see that repo's runbook.

## Standards

See the iac-foundry `docs/` repo, starting at `docs/AGENTS.md`:
`docs/standards/BLUEPRINTS_TERRAFORM_MODULE_STANDARDS.md`,
`docs/standards/REPOSITORY_NAMING_STANDARD.md`,
`docs/design/BLUEPRINTS_DESIGN_PRINCIPLES.md`.
