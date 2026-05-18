#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-site}"
mkdir -p "$out_dir"

cat > "$out_dir/index.html" <<'HTML'
<!doctype html>
<html lang="zh-Hant">
<head><meta charset="utf-8"><title>AWS DR Gameday Lab</title></head>
<body>
  <h1>AWS DR Gameday Lab</h1>
  <p>Primary/DR S3 static website demo. Replace this file during gameday tests.</p>
</body>
</html>
HTML

cat > "$out_dir/error.html" <<'HTML'
<!doctype html>
<html lang="zh-Hant">
<head><meta charset="utf-8"><title>DR Lab Error</title></head>
<body><h1>DR Lab Error</h1><p>Static website error page.</p></body>
</html>
HTML

echo "Rendered demo site in $out_dir"
