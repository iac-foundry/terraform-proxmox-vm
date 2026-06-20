# Example: basic VM clone

Minimal caller used to validate the module. Placeholder values only.

```bash
# Through the pinned container (preferred — no reliance on local tools):
docker compose run --rm terraform -chdir=examples/basic init -backend=false
docker compose run --rm terraform -chdir=examples/basic validate

# Or with a local Terraform:
cd examples/basic
terraform init -backend=false
terraform validate
```

A real `plan`/`apply` needs Proxmox API access (set `PROXMOX_VE_ENDPOINT`,
`PROXMOX_VE_USERNAME`, `PROXMOX_VE_PASSWORD`) and a real `node`/`template_name`.
