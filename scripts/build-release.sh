#!/usr/bin/env bash
# Empacota a skill para distribuição. Substitui o .zip que ficava commitado.
#
#   scripts/build-release.sh            # versão lida do SKILL.md
#   scripts/build-release.sh 0.4        # versão explícita
#
# Saída: dist/skill-dashproject_v<versao>.zip (dist/ está no .gitignore)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

version="${1:-}"
if [[ -z "$version" ]]; then
  version=$(sed -n 's/^  version: "\(.*\)"$/\1/p' SKILL.md | head -1)
fi
[[ -n "$version" ]] || { echo "não consegui determinar a versão (veja SKILL.md)" >&2; exit 1; }

command -v zip >/dev/null || { echo "'zip' não está instalado" >&2; exit 1; }

out="dist/skill-dashproject_v${version}.zip"
mkdir -p dist
rm -f "$out"

# Só o que a skill precisa em runtime. Docs do repositório, .claude/ e .continue/
# são ferramentas de desenvolvimento e ficam de fora do pacote.
zip -q -r "$out" \
  SKILL.md \
  README.md \
  LICENSE \
  references \
  scripts \
  assets \
  -x 'scripts/build-release.sh' \
  -x '*/__pycache__/*'

echo "$out"
unzip -l "$out" | tail -1
