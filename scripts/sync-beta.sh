#!/usr/bin/env bash
# Recopie dans cornelius_beta/ ce que la bêta partage avec l'application stable : Dockerfile,
# services s6, traductions, visuels et documentation (précédée d'un avertissement).
# La bêta garde les siens : config.yaml, source.env, CHANGELOG.md et README.md.
#   scripts/sync-beta.sh          recopie
#   scripts/sync-beta.sh --check  échoue si la bêta n'est pas à jour (CI)
set -euo pipefail
cd "$(dirname "$0")/.."

shared=(Dockerfile rootfs translations icon.png logo.png)
notice="$(cat <<'TEXTE'
> [!WARNING]
> **Version bêta.** Cette application suit la branche `beta` de Cornelius : fonctions en cours, pas encore publiées, parfois cassées. Elle a ses propres données et ses propres ports (`3444` en HTTPS, `3001` en interne) : elle peut tourner à côté de la version stable, mais la base de l'une ne passe pas dans l'autre. Pour un miroir de tous les jours, installez **Cornelius**.
TEXTE
)"

render() { # $1 : dossier de destination
  local out="$1"
  mkdir -p "$out"
  for item in "${shared[@]}"; do
    rm -rf "${out:?}/$item"
    cp -R "cornelius/$item" "$out/$item"
  done
  # Titre, avertissement, puis le reste de la documentation stable.
  { head -n 2 cornelius/DOCS.md; printf '%s\n\n' "$notice"; tail -n +3 cornelius/DOCS.md; } >"$out/DOCS.md"
}

if [[ "${1:-}" == "--check" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  render "$tmp"
  for item in "${shared[@]}" DOCS.md; do
    if ! diff -r "$tmp/$item" "cornelius_beta/$item" >/dev/null; then
      echo "cornelius_beta/$item n'est pas à jour : lancez scripts/sync-beta.sh" >&2
      exit 1
    fi
  done
  echo "La bêta est à jour."
else
  render cornelius_beta
  echo "cornelius_beta/ recopiée depuis cornelius/."
fi
