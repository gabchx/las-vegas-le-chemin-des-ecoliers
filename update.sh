#!/usr/bin/env bash
# Publie la dernière version road-trip-vegas-*.html sur GitHub Pages.
set -euo pipefail
cd "$(dirname "$0")"

latest=$(ls road-trip-vegas-*.html 2>/dev/null | sort | tail -1)
if [[ -z "$latest" ]]; then
  echo "Aucun fichier road-trip-vegas-*.html trouvé." >&2
  exit 1
fi

# "…_2026-10-24_19h44.html" → "Version du 24/10/2026 à 19h44"
stamp=$(sed -E 's/.*_([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2}h[0-9]{2})\.html$/\3\/\2\/\1 à \4/' <<<"$latest")
badge="<p id=\"page-version\" style=\"text-align:center;font:13px var(--body);color:var(--muted);margin:24px 16px 32px\">Version du $stamp</p>"

# Insère le badge avant le dernier </body>
BADGE="$badge" perl -0pe 's/(.*)<\/body>/$1$ENV{BADGE}\n<\/body>/s' "$latest" > index.html
git add index.html "$latest"

if git diff --cached --quiet; then
  echo "Déjà à jour ($latest)."
  exit 0
fi

git commit -q -m "Update page ($latest)"
git push -q origin main
git push -q origin main:gh-pages
echo "Publié : $latest → https://gabchx.github.io/las-vegas-le-chemin-des-ecoliers/"
