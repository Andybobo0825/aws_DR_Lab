#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=infra init -backend=false -input=false
terraform -chdir=infra validate
