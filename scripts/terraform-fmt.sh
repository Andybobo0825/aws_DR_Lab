#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=infra fmt -recursive "$@"
