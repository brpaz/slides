#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="$root/dist"

# GitHub Pages serves this repo under /slides/ (project page, not a user/org root page).
base_prefix="${BASE_PREFIX:-/slides/}"

rm -rf "$dist"
mkdir -p "$dist"

cards=""

html_escape() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$1"
}

for deck_dir in "$root"/decks/*/; do
  name="$(basename "$deck_dir")"
  entry="$deck_dir/slides.md"
  [ -f "$entry" ] || continue

  deck_base="${base_prefix}${name}/"

  echo "==> building deck: $name"
  pnpm exec slidev build "$entry" --base "$deck_base" --out "$dist/$name"

  title="$(sed -n 's/^title:[[:space:]]*//p' "$entry" | head -1)"
  desc="$(sed -n 's/^description:[[:space:]]*//p' "$entry" | head -1)"
  [ -n "$title" ] || title="$name"

  cards="$cards
    <a class=\"card\" href=\"./$name/\">
      <p class=\"card-title\">$(html_escape "$title")</p>
      $( [ -n "$desc" ] && printf '<p class="card-desc">%s</p>' "$(html_escape "$desc")" )
      <span class=\"card-open\">Open deck &rarr;</span>
    </a>"
done

if [ -z "$cards" ]; then
  cards="<p class=\"empty\">No decks yet — add one under decks/&lt;name&gt;/slides.md</p>"
fi

template="$root/site/index.template.html"
before="$(sed -n '1,/<!--DECK_CARDS-->/p' "$template" | sed '$d')"
after="$(sed -n '/<!--DECK_CARDS-->/,$p' "$template" | sed '1d')"
{ printf '%s\n' "$before"; printf '%s\n' "$cards"; printf '%s\n' "$after"; } > "$dist/index.html"

echo "==> done. output in $dist"
