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

**verification** — eixo paralelo com três campos independentes:
`implementation`, `tests` e `documentation`, cada um `verified` / `partial` /
`pending`. É aqui que foram parar os estados `IMPLEMENTED`, `TESTED` e
`VERIFIED` do desenho original ([ADR-0007](adr/0007-um-numero-e-tres-estados.md)).
**Nunca move o percentual** — são três verdades simultâneas sobre o mesmo
requisito, não posições numa régua.

**evidence pointers** — `evidence.implementation`, `evidence.tests` e
`evidence.docs`: caminhos relativos que sustentam a classificação. Sem eles o
auditor não é auditável, e a fórmula de `confidence` pontua um ponteiro que o
schema não guarda.

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

**épico** — agrupador de requisitos. O progresso do épico é a média dos
requisitos ativos dele — mesma fórmula do projeto, sobre um subconjunto. Épico
**não tem peso** e o progresso do épico **não alimenta** o número do projeto,
que é calculado uma vez sobre todos os requisitos ativos.

**delta** — variação em relação ao snapshot anterior: `progress`, `completed`,
`started`. É o que responde "o que mudou nesse burst?".

**divergência** — diferença entre o que a documentação diz (esperado) e o que o
código faz (real). Mora em `analysis/divergences.yaml`, com `type` ∈ `missing`,
`partial`, `unexpected_implementation`. **Não é um status** de requisito — foi
uma proposta recusada ([ADR-0007](adr/0007-um-numero-e-tres-estados.md)).

**regressão** — um requisito que estava `COMPLETED` num snapshot anterior e
deixou de estar. Vai para `regressions` no snapshot. Três coisas parecidas e
distintas:

| | O que é |
|---|---|
| regressão | requisito perdeu o COMPLETED entre snapshots |
| `rejected_claims` | pretensão recusada dentro do burst; nunca chegou a COMPLETED |
| escopo cresceu | denominador aumentou, o % caiu e **nada regrediu** |

**escalate** — condições em `config.yaml` que trocam o modelo do ciclo para um
mais caro: `low_confidence` e `major_divergence`. Escalona a validação **daquele
requisito**, não o burst inteiro.

**Pulse** — resumo de atividade do repositório: arquivos, criados na semana,
commits, churn. Nunca é convertido em percentual de projeto.

**Churn** — arquivos únicos criados + modificados + apagados na janela.

**Reality Map** — `agent-docs/implementation-map.md`: o que o código **é**, em
oposição ao `docs/` oficial, que descreve o que o sistema **deveria ser**.
