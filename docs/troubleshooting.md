# Troubleshooting

## O hook não grava `pending`

```bash
ls -l .git/hooks/post-commit          # existe e é executável?
bash -n .git/hooks/post-commit        # erro de sintaxe?
bash -x .git/hooks/post-commit        # o que acontece de fato
```

Causas comuns:

- O hook não tem bit de execução → `chmod +x .git/hooks/post-commit`.
- O commit começa com `chore(dashproject)` — é **ignorado de propósito**.
- O repositório usa `core.hooksPath` apontando para outro diretório:
  `git config core.hooksPath` e instale lá.

Reinstalar é seguro e idempotente — o bloco entre os marcadores é substituído,
o resto do hook é preservado:

```bash
scripts/install-git-hook.sh
```

## Nasce um commit sozinho a cada tantos minutos, e o `pending` volta

Sintoma: uma sequência de commits automáticos tocando só `.dashproject/`, cada um
rearmando a revisão seguinte — inclusive com a máquina parada.

O gatilho de quem commita sozinho (a skill **COMMITTER**, por exemplo) não é o
commit: é a **árvore suja**. O hook grava `pending` e `last-commit-ts` *depois* de
cada commit, então num projeto que versiona `.dashproject/` a árvore fica suja no
instante seguinte a qualquer commit; o outro ciclo empacota aquilo, e o commit dele
— que não começa com `chore(dashproject)` — rearma o hook.

Duas metades resolvem, e as duas são necessárias:

```bash
grep -n auto_commit .dashproject/config.yaml   # true: o review fecha a árvore
grep -n skip_paths .committer.yml              # .dashproject/ fora do stage do COMMITTER
```

A primeira fecha a árvore depois da revisão; a segunda cobre os 10 minutos de
debounce e o caso em que a revisão não roda. Veja
[ADR-0014](adr/0014-auditor-fecha-a-propria-arvore.md).

## `pending-ready.sh` sempre diz `wait`

Ele compara `now - last-commit-ts` com `debounce_minutes`. Cada commit novo
**reinicia** a janela — é o comportamento esperado num burst. Para conferir:

```bash
cat .dashproject/last-commit-ts
grep debounce_minutes .dashproject/config.yaml
scripts/pending-ready.sh; echo "exit=$?"     # 0 = devido, 2 = ainda esperando
```

Códigos de saída: `0` review devido · `1` sem `pending` · `2` dentro do debounce.

## O watcher roda mas o review nunca acontece

Isso é o desenho, não um defeito. O watcher **não chama modelo** — ele só grava
`.dashproject/review-due`. Quem executa o review é a sessão do agente ao ver
esse arquivo. Se ninguém abriu uma sessão, nada acontece.

`review_notify` no `config.yaml` é um comando local (ex.: `notify-send`), não um
gatilho de LLM.

## Série `growth` toda zerada no `repository.json`

`collect-activity.py` monta a série com `git rev-list -1 --before=<data>`. Num
repositório cujo primeiro commit é recente, todas as semanas anteriores ao
primeiro commit são legitimamente `0`. Confirme:

```bash
git log --reverse --date=short --pretty='%ad %h %s' | head -1
```

Se o primeiro commit é de ontem, sete semanas de zeros estão corretas.

## Contagem de arquivos "errada"

`collect-activity.py` só enxerga o que está **rastreado pelo Git**.
`node_modules/`, `vendor/`, `dist/` e afins não entram a menos que alguém os
tenha commitado. Isso é intencional.

```bash
git ls-files | wc -l          # é essa a base da contagem
```

## O progresso caiu sem ninguém regredir nada

Provavelmente o escopo cresceu. Confira no snapshot:

```yaml
scope: { original: 287, current: 301, added: 14, removed: 0 }
```

172 completos em 287 dá 60,0%. Os mesmos 172 em 301 dão 57,1%. O projeto não
regrediu — ele cresceu. O snapshot deve trazer essa explicação.

## Um `COMPLETED` foi recusado

Aparece como `rejected_claims` no snapshot e o requisito **volta ao status
anterior**. O motivo fica registrado — normalmente "o diff não toca o módulo do
requisito". O caminho é commitar a implementação de verdade e declarar de novo.

## Documentação fora do padrão

```bash
scripts/check-docs.sh
```

Verifica versão consistente, links relativos quebrados, arquivos obrigatórios na
raiz e artefato de build versionado.
