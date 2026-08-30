#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="$root/dist"

rm -rf "$dist"
mkdir -p "$dist"

links=""

for deck_dir in "$root"/decks/*/; do
  name="$(basename "$deck_dir")"
  entry="$deck_dir/slides.md"
  [ -f "$entry" ] || continue

  echo "==> building deck: $name"
  pnpm exec slidev build "$entry" --base "/$name/" --out "$dist/$name"

  links="$links<li><a href=\"./$name/\">$name</a></li>"
done

cat > "$dist/index.html" <<HTML
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Slides</title></head>
<body>
<h1>Slides</h1>
<ul>
$links
</ul>
</body>
</html>
HTML

echo "==> done. output in $dist"
