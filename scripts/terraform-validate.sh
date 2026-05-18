#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
terraform -chdir="$ROOT/infra" init -backend=false -input=false
terraform -chdir="$ROOT/infra" validate
