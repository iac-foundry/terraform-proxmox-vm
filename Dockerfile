# Pinned Terraform toolchain for this repo.
#
# We deliberately do NOT rely on locally-installed tools: execution (fmt,
# validate, plan, apply) runs inside this image so the toolchain is pinned,
# reproducible, and resilient across machines and CI. Bump the version here
# deliberately, in a reviewed change — never float.
FROM hashicorp/terraform:1.15.6

# Add further pinned tooling here as the repo needs it, e.g.:
#   RUN apk add --no-cache jq
#   COPY --from=ghcr.io/terraform-linters/tflint:v0.58.0 /usr/local/bin/tflint /usr/local/bin/tflint

WORKDIR /work
ENTRYPOINT ["terraform"]
