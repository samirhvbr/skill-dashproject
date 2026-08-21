#!/usr/bin/env bash
# Verifica a consistência da documentação deste repositório.
# Referência do padrão: docs/padrao-documentacao.md
#
# Saída: 0 = tudo certo, 1 = há falhas.
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

fail=0
ok()    { printf "  \033[32mok\033[0m    %s\n" "${1:-}"; }
bad()   { printf "  \033[31mFALHA\033[0m %s\n" "${1:-}"; fail=1; }
head_() { printf "\n\033[1m%s\033[0m\n" "${1:-}"; }

# ---------------------------------------------------------------- versão
head_ "Versão"

skill_v=$(sed -n 's/^  version: "\(.*\)"$/\1/p' SKILL.md | head -1)
readme_v=$(sed -n 's/^Versão: \([0-9][0-9.]*\).*/\1/p' README.md | head -1)
chlog_v=$(sed -n 's/^## \[\([0-9][0-9.]*\)\].*/\1/p' CHANGELOG.md | head -1)

if [[ -z "$skill_v" ]]; then
  bad "SKILL.md não declara metadata.version"
else
  ok "SKILL.md   version = $skill_v (canônica)"
  [[ "$readme_v" == "$skill_v" ]] \
    && ok "README.md  Versão  = $readme_v" \
    || bad "README.md diz '$readme_v', SKILL.md diz '$skill_v'"
  [[ "$chlog_v" == "$skill_v" ]] \
    && ok "CHANGELOG  topo    = $chlog_v" \
    || bad "CHANGELOG.md topo é '$chlog_v', SKILL.md diz '$skill_v'"
fi

# ------------------------------------------------ arquivos obrigatórios
head_ "Arquivos obrigatórios na raiz"
for f in README.md SKILL.md CLAUDE.md CONTRIBUTING.md CHANGELOG.md LICENSE \
         .gitignore .editorconfig; do
  [[ -f "$f" ]] && ok "$f" || bad "$f está faltando"
done

head_ "Pastas do padrão"
for d in docs docs/adr .claude .continue scripts assets references; do
  [[ -d "$d" ]] && ok "$d/" || bad "$d/ está faltando"
done

# --------------------------------------------- licença declarada × arquivo
head_ "Licença"
declared=$(sed -n 's/^license: *//p' SKILL.md | head -1)
if [[ -n "$declared" && ! -f LICENSE ]]; then
  bad "SKILL.md declara license: $declared mas não existe LICENSE"
elif [[ -n "$declared" ]]; then
  ok "license: $declared com arquivo LICENSE presente"
else
  ok "nenhuma licença declarada no frontmatter"
fi

# --------------------------------------------------- artefatos de build
head_ "Artefatos de build"
tracked_zip=$(git ls-files '*.zip' 2>/dev/null)
if [[ -n "$tracked_zip" ]]; then
  bad "arquivo(s) de build versionado(s): $tracked_zip — use scripts/build-release.sh"
else
  ok "nenhum .zip versionado"
fi
if git ls-files --error-unmatch .dashproject >/dev/null 2>&1; then
  bad ".dashproject/ está versionado — é saída do auditor, não fonte"
else
  ok ".dashproject/ não versionado"
fi

# ------------------------------------------------------- links relativos
head_ "Links relativos em Markdown"
broken=0; checked=0
while IFS= read -r md; do
  base=$(dirname "$md")
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    case "$target" in
      http://*|https://*|mailto:*|\#*) continue ;;
    esac
    target=${target%%#*}
    [[ -z "$target" ]] && continue
    checked=$((checked + 1))
    if [[ ! -e "$base/$target" ]]; then
      bad "$md → $target"
      broken=$((broken + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$md" | sed 's/^](//; s/)$//')
done < <(git ls-files '*.md' 2>/dev/null)
(( broken == 0 )) && ok "$checked link(s) relativo(s), nenhum quebrado"

# ------------------------------------------------------------- sintaxe
head_ "Sintaxe"
for s in scripts/*.sh; do
  bash -n "$s" 2>/dev/null && ok "$s" || bad "$s tem erro de sintaxe"
done
if python3 -m py_compile scripts/collect-activity.py 2>/dev/null; then
  ok "scripts/collect-activity.py"
  rm -rf scripts/__pycache__
else
  bad "scripts/collect-activity.py não compila"
fi

# --------------------------------------------------------------- final
echo
if (( fail )); then
  printf '\033[31mdocumentação fora do padrão\033[0m — veja docs/padrao-documentacao.md\n'
  exit 1
fi
printf '\033[32mdocumentação dentro do padrão\033[0m\n'
