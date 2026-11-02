#!/usr/bin/env bash
# Fait suivre à un canal une version de Cornelius : commit épinglé (source.env), version de
# l'application (config.yaml) et entrée du CHANGELOG. Ne change rien si le canal est à jour.
#   scripts/bump.sh stable [tag]           dernière release de Cornelius, ou ce tag
#   scripts/bump.sh beta [branche|commit]  tête de la branche beta, ou ce commit
# Demande gh, connecté (GH_TOKEN dans GitHub Actions).
set -euo pipefail
cd "$(dirname "$0")/.."

repo=lfpoulain/Cornelius
modules_repo=lfpoulain/cornelius-modules
channel="${1:-}"
ref="${2:-}"
case "$channel" in
  stable) dir=cornelius ;;
  beta) dir=cornelius_beta ;;
  *)
    echo "usage : scripts/bump.sh stable [tag] | beta [branche|commit]" >&2
    exit 2
    ;;
esac

if [[ "$channel" == stable ]]; then
  ref="${ref:-$(gh api "repos/$repo/releases/latest" --jq .tag_name)}"
else
  ref="${ref:-beta}"
fi
commit="$(gh api "repos/$repo/commits/$ref" --jq .sha)"
modules="$(gh api "repos/$modules_repo/commits/main" --jq .sha)"
cornelius_version="$(gh api "repos/$repo/contents/package.json?ref=$commit" \
  -H 'Accept: application/vnd.github.raw' --jq .version)"

# shellcheck source=/dev/null
. "$dir/source.env"
previous="$CORNELIUS_COMMIT"
previous_modules="$CORNELIUS_MODULES_COMMIT"

if [[ "$channel" == stable ]]; then
  # Une release ne bouge plus : ses modules sont ceux du jour où l'application la suit.
  [[ "$commit" == "$previous" ]] && modules="$previous_modules"
  version="${ref#v}"
  label="$ref"
else
  version="$cornelius_version-beta.${commit:0:7}"
  # Une branche garde son nom ; un commit choisi à la main est noté par son SHA.
  [[ "$ref" == "$commit" || "$commit" == "$ref"* ]] && label="${commit:0:7}" || label="$ref"
fi

if [[ "$commit" == "$previous" && "$modules" == "$previous_modules" ]]; then
  echo "$channel est déjà à jour : Cornelius $label (${commit:0:7})."
  [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "changed=false" >>"$GITHUB_OUTPUT"
  exit 0
fi

cat >"$dir/source.env" <<EOF
# Cornelius contenu dans ce canal. Fichier tenu par scripts/bump.sh : ne pas le modifier à la main.
CORNELIUS_REF=$label
CORNELIUS_COMMIT=$commit
CORNELIUS_MODULES_COMMIT=$modules
EOF
sed -i "s/^version: .*/version: \"$version\"/" "$dir/config.yaml"

# Entrée du CHANGELOG, insérée avant la première version.
url="https://github.com/$repo"
entry="## $version · $(date -u +%F)"$'\n\n### Changé\n\n'
if [[ "$channel" == stable ]]; then
  entry+="- Cornelius [$version]($url/releases/tag/$ref) (commit \`${commit:0:7}\`) : les nouveautés sont dans ses notes de version."$'\n'
else
  origin=""
  [[ "$label" != "${commit:0:7}" ]] && origin=" (\`$label\`)"
  entry+="- Cornelius au commit [\`${commit:0:7}\`]($url/commit/$commit)$origin : [changements depuis la bêta précédente]($url/compare/$previous...$commit)."$'\n'
fi
if [[ "$modules" != "$previous_modules" ]]; then
  entry+="- cornelius-modules au commit [\`${modules:0:7}\`](https://github.com/$modules_repo/commit/$modules)."$'\n'
fi
ENTRY="$entry" node -e '
  const fs = require("fs");
  const file = process.argv[1];
  const text = fs.readFileSync(file, "utf8");
  const at = text.indexOf("\n## ") + 1;
  fs.writeFileSync(file, text.slice(0, at) + process.env.ENTRY + "\n" + text.slice(at));
' "$dir/CHANGELOG.md"

echo "$channel : Cornelius $label (${commit:0:7}), application $version."
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "changed=true"
    echo "version=$version"
    echo "label=$label"
  } >>"$GITHUB_OUTPUT"
fi
