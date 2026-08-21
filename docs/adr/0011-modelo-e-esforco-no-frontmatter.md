# ADR-0011 — Modelo e esforço do auditor no frontmatter; escalonamento é hand-off

**Status:** Aceito · v0.4.1

## Contexto

`config.yaml` declara desde a v0.1 qual modelo opera o auditor:

```yaml
analysis:
  provider: anthropic
  model: sonnet
  escalate:
    bootstrap: opus
    low_confidence: opus
    release: opus
    major_divergence: opus
```

E [references/cycles.md](../../references/cycles.md) explica o porquê — custo
contra frequência e reversibilidade: *"o que roda a cada burst usa o modelo
barato; o que é lido uma vez e é difícil de desfazer usa o caro."*

A medição no primeiro repositório real da casa (`~/x/EOP`, 21/08/2026) mostrou
que **nada disso era imposto**:

- Não existia definição de agente para a skill — nem em `~/.claude/agents/`, nem
  em `<repo>/.claude/agents/`. A skill nunca rodou num subagente.
- `SKILL.md` não declarava `model` nem `effort`. A skill herdava o **modelo da
  sessão**: naquele momento, Opus 5 em `effort: high` — o oposto do que o
  `config.yaml` declarava para o caminho incremental.
- Os scripts não chamam modelo (ADR-0003), então não há lugar onde
  `analysis.model` seja lido para decidir coisa alguma.
- `scripts/render-reports.py` imprime `- model: {d.get("model")}` — um campo
  **auto-declarado** pelo agente que rodou. O relatório repetia a declaração em
  vez de observar o fato.

Ou seja: `analysis.model` era um comentário em YAML. É a classe de defeito que a
casa chama de **declarado ≠ imposto** — um controle que não prova que roda é
indistinguível de um controle que não existe.

## Decisão

1. **`SKILL.md` declara `model: sonnet` e `effort: medium` no frontmatter.** É o
   único ponto que o Claude Code lê para escolher modelo e esforço ao ativar a
   skill, e ele passa a valer para o caminho **rotineiro** — o review incremental
   depois do burst de commits.
2. O valor de `model` no frontmatter e o de `analysis.model` no
   `assets/templates/config.yaml` são **o mesmo string**. `scripts/check-docs.sh`
   reprova divergência entre os dois.
3. **`analysis.escalate` não se executa sozinho — vira hand-off explícito.** Uma
   skill não troca o próprio modelo no meio da execução. Em `bootstrap`, `deep`,
   `release`, ou ao bater `low_confidence` / `major_divergence`, o auditor
   **para e pede** que o operador rode de novo sob o modelo escalado. É proibido
   gravar status a partir de uma condição de escalonamento continuando no modelo
   rotineiro e chamar aquilo de escalado.
4. O campo `model` de `analysis/latest.yaml` e de `dashboard/data.json` é o
   modelo **que de fato rodou**, nunca uma cópia de `config.yaml`. Divergência
   entre os dois aparece na linha de relato.

## Consequências

- O caminho barato passa a ser barato de verdade: o review de cada burst roda em
  sonnet/medium mesmo quando a sessão do dono está em opus/high, que é o caso
  comum num repositório em obra.
- `bootstrap` fica **mais caro em atrito**: em vez de escalar sozinho, o auditor
  interrompe e pede a troca. É deliberado — bootstrap escreve o mapa inteiro de
  requisitos, e um mapa escrito no modelo errado é caro de desfazer.
- O relatório ganha um fato onde antes tinha uma declaração. Se alguém rodar o
  auditor em outro modelo, o `latest.yaml` registra isso e o dashboard mostra.
- **Portabilidade do pacote:** `model` e `effort` são campos do Claude Code. O
  empacotador oficial da Anthropic (`package_skill.py` / upload em claude.ai)
  valida um conjunto fechado de 6 campos e **falha duro** com campo extra.
  `scripts/build-release.sh` é um `zip` e não valida nada, então o pacote da casa
  continua saindo; publicar na Skills API exigirá remover as duas linhas ou o
  campo entrar no spec. Fica registrado como limite conhecido, não como surpresa.
- Não muda schema de `.dashproject/`, não invalida ledger existente, não mexe em
  progresso.

## Alternativas descartadas

- **Criar `.claude/agents/dashproject.md` e rodar a skill num subagente** —
  funciona (`model` e `effort` valem lá), mas acrescenta um artefato que a skill
  teria de instalar no repositório alvo, e um agente separado perde o contexto da
  sessão que acabou de commitar. O frontmatter é o caminho curto e sem
  instalação.
- **Fazer os scripts lerem `analysis.model` e roteá-lo** — quebraria o ADR-0003
  (`hook e watcher nunca chamam modelo`). O roteamento tem de ficar do lado do
  agente.
- **Deixar `analysis.model` como está e documentar que é indicativo** — é
  exatamente o defeito que este ADR fecha. Declaração que nada observa não vira
  verdade por ser documentada.
- **Pinar `claude-sonnet-5` em vez do alias `sonnet`** — o alias já é o que o
  `config.yaml` diz há três versões, e manter dois strings diferentes para a
  mesma escolha recria a divergência que a decisão 2 elimina. O alias resolve
  para Sonnet 5 hoje; quando isso mudar, muda nos dois lugares de uma vez e a
  perna do `check-docs.sh` continua provando que estão iguais.
