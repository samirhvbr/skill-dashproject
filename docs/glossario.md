# Glossário

**Requirement (REQ-NNN)** — menor unidade auditável. Um comportamento visível
para o usuário ou um contrato duro de infraestrutura. Um rename não é requisito.
IDs são estáveis e nunca reciclados.

**status** — `PLANNED`, `IN_PROGRESS` ou `COMPLETED`. É a **fonte da verdade**.

**progress (derivado)** — `PLANNED→0`, `IN_PROGRESS→50`, `COMPLETED→100`. Nunca
é gravado na linha do ledger; é sempre recalculado a partir de `status`.

**Progress do projeto** — média aritmética do progresso derivado dos requisitos
ativos (`withdrawn != true`).

**completion** — segundo campo que só existe quando `status: COMPLETED`:

| valor | significado |
|---|---|
| `declared` | implementação plausível, testes/docs fracos — continua valendo 100 |
| `accepted` | implementação **e** testes presentes |
| `rejected` | pretensão recusada; o status **não** fica COMPLETED |

**evidence.knownness** — `unknown` / `partial` / `known`. Qualidade da
*informação* sobre o requisito, não do progresso. Existe para impedir que um
arquivo com nome parecido vire `COMPLETED` no bootstrap.

**confidence** — 0–100 por requisito. Cai 15 pontos se a mesma sessão escreveu
o código auditado. Piso 5.

**baseline_confidence** — 0–100, gravado **só** no snapshot de bootstrap.
Mede o quanto a leitura inicial do escopo já feito é confiável.

**Measurement Precision** — 0–100 para o projeto inteiro. Quatro fatores:
clareza (25), granularidade (20), rastreabilidade de commits (35), qualidade da
documentação (20). É independente do progresso: 62,4% com precision 57% é um
número aritmeticamente exato e pouco confiável.

**Scope** — `original`, `current`, `added`, `removed`. Requisito novo aumenta o
denominador; a queda de % que vem daí **não é regressão** e deve ser explicada
no snapshot.

**withdrawn** — requisito removido do escopo. A linha permanece com
`withdrawn: true` e sai do denominador. O ID nunca é reaproveitado.

**Burst** — sequência de commits sem `debounce_minutes` de silêncio entre eles.
Um burst gera **um** review incremental sobre `BASE..HEAD`.

**Debounce** — janela de silêncio (padrão 10 min) antes de o review ser devido.

**pending / review-due** — arquivos-sinal em `.dashproject/`. `pending` é escrito
pelo hook a cada commit; `review-due` é escrito pelo watcher quando o debounce
venceu. Nenhum dos dois chama modelo.

**Pulse** — resumo de atividade do repositório: arquivos, criados na semana,
commits, churn. Nunca é convertido em percentual de projeto.

**Churn** — arquivos únicos criados + modificados + apagados na janela.

**Reality Map** — `agent-docs/implementation-map.md`: o que o código **é**, em
oposição ao `docs/` oficial, que descreve o que o sistema **deveria ser**.
