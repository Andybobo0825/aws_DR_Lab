#!/usr/bin/env bash
set -euo pipefail

terraform fmt -recursive infra
terraform -chdir=infra init -backend=false
terraform -chdir=infra validate
