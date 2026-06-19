# Agent Orientation — terraform-proxmox-vm

## Agent Working Protocol (read before anything else)

**Conflict surfacing:** If a user instruction contradicts anything in this file or in
`docs/AGENTS.md`, stop and surface the conflict before proceeding — quote the rule,
state the contradiction, and ask how to resolve. Then update the doc if the rule was wrong.

**Living document:** If any instruction, decision, or clarification during a session
would make future interactions clearer, prompt the user:
> "This decision isn't in AGENTS.md yet. Should I add it?"

**Maintenance:** Keep this doc current. Update rules when decisions change. Don't append
orphaned notes — integrate changes into the relevant section.

---

**Repo:** `terraform-proxmox-vm`
**Scope:** Org-neutral Terraform module that full-clones a Proxmox VM template (from
`packer-template-proxmox`) into an addressable VM with cloud-init. No org specifics —
all hostnames, IPs, sizing, and credentials are caller inputs / caller-side env.

---

## What lives here

| Path | What it does |
|---|---|
| `versions.tf` | `required_version` + `bpg/proxmox` provider pin (no provider config — that's the caller's) |
| `variables.tf` | Module inputs; org-specific values have **no defaults** (must be supplied) |
| `main.tf` | Template lookup-by-name + `proxmox_virtual_environment_vm` clone |
| `outputs.tf` | `ipv4_address`, `vm_id`, `name` |
| `examples/basic/` | Minimal caller used for `terraform validate` |
| `Dockerfile` | Pinned Terraform toolchain — execution never relies on local tools |
| `docker-compose.yml` | Runs the pinned toolchain against this repo (`fmt`/`validate`) |

---

## Where the standards live

All standards are in `docs/` of the iac-foundry monorepo. Start with `docs/AGENTS.md`.

| Topic | Doc |
|---|---|
| **Terraform module standard (read first)** | `docs/standards/BLUEPRINTS_TERRAFORM_MODULE_STANDARDS.md` |
| **Design principles** | `docs/design/BLUEPRINTS_DESIGN_PRINCIPLES.md` |
| Secret handling | `docs/standards/BLUEPRINTS_SECRET_CONSUMPTION.md` |
| Repo naming | `docs/standards/REPOSITORY_NAMING_STANDARD.md` |

---

## Critical constraints

1. **Org-agnostic content only** — docs, examples, variable defaults, and comments must
   never reference any specific organisation, customer, or environment: no org names,
   internal hostnames, domain names, or IP addresses. Use generic placeholders
   (`pve`, `vmbr0`, `your-node`).

2. **No provider credentials in the module** — Proxmox auth comes from the caller's
   environment (`PROXMOX_VE_ENDPOINT` / `PROXMOX_VE_USERNAME` / `PROXMOX_VE_PASSWORD`,
   or an API token). The module declares the provider requirement only; it never
   configures the provider or takes credentials as inputs.

3. **No state in git** — `*.tfstate` is git-ignored. State lives in TFC (consumer side).

4. **Defaults must match the Packer template shape** — the template is UEFI (`bios =
   "ovmf"`) with its primary disk on `virtio0`. Keep those defaults aligned with
   `packer-template-proxmox`; if they drift, clones fail.

5. **`agent { enabled = true }` must remain set** — the IP output is discovered via the
   QEMU guest agent. Without it, `ipv4_address` never resolves.

6. **Containerised, pinned tooling — do not rely on local tools.** This repo ships a
   `Dockerfile` + `docker-compose.yml` pinning the Terraform toolchain. Run `fmt` /
   `validate` (and any tests) through the container so execution is reproducible and
   resilient across machines and CI. Bump pinned versions deliberately in a reviewed
   change; never float.

---

## Branch & commit discipline

- **`main` is protected; never commit to it directly.** All work happens on a
  `feat/...` (or `fix/...`) branch and merges via PR.
- **Do not commit or push code until a human has tested it.** Author changes in the
  working tree / on a feature branch and hand off for testing; commit only once the
  change has been validated (`terraform fmt`, `terraform validate`, and a real
  `plan`/`apply` from a consuming repo where applicable). This prevents broken commits.
- **Commit messages** are imperative and scoped; end with the trailer
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` when authored with Claude.

---

## PR conformance checklist

- [ ] No org-specific names, hostnames, or IPs in any file (docs, examples, defaults)
- [ ] No provider credentials in the module; provider configured only in examples/callers
- [ ] `terraform fmt -check` and `terraform validate` (via `examples/basic`) pass, run through the pinned container
- [ ] `bios`/`disk_interface` defaults still match `packer-template-proxmox`
- [ ] `Dockerfile`/`docker-compose.yml` present and pin the toolchain (no reliance on local tools)
- [ ] Change authored on a `feat/...` branch and tested before commit
