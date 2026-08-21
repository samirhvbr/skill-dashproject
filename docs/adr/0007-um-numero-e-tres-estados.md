# ADR-0007 — Um número de progresso, três estados de requisito

**Status:** Aceito · v0.3 (registro retroativo) · Complementa o
[ADR-0001](0001-progresso-discreto.md), não o substitui

## Contexto

O desenho inicial tinha duas ambições que foram cortadas juntas, e o corte
nunca foi registrado.

**Um índice composto de seis dimensões:**

```
PROJECT HEALTH
Implementation 78 · Testing 64 · Documentation 82
Specification 91 · Quality 87 · Security 73
OVERALL 77
```

com pesos por dimensão (`implementation 40, tests 20, specification 15,
documentation 10, quality 10, security 5`).

**Uma máquina de sete estados:**

```
PLANNED  IN_PROGRESS  IMPLEMENTED  TESTED  VERIFIED  BLOCKED  DIVERGED
```

Os dois foram substituídos pela unidade requisito 0/50/100. A regra que fechou
a questão: `test`/`docs` valem como upgrade de *acceptance*, não como novo
percentual — "senão voltamos a misturar evidência com progresso".

O ADR-0001 fixou a escala, mas suas alternativas descartadas listam só
percentual livre, story points e escala de cinco níveis. O composto ponderado e
a máquina de sete estados ficaram de fora do registro.

E o resíduo sobreviveu no código: `assets/templates/project.yaml` carregava um
bloco `tracking:` com `commits / tests / documentation / security /
architecture` — chaves que nenhum arquivo do repositório lia, que
`docs/arquitetura.md` nem mencionava, e que o bootstrap copiava para dentro de
todo projeto auditado.

## Decisão

**1. Um número.** `Progress = média de 0/50/100 sobre requisitos ativos`. Não
existe OVERALL ponderado por dimensão, nem barras de Implementation, Testing,
Documentation, Specification, Quality ou Security como percentual.

**2. Três status.** A migração dos sete fica registrada:

| Estado proposto | Para onde foi |
|---|---|
| `PLANNED` / `IN_PROGRESS` | `status` (0 / 50) |
| `IMPLEMENTED` · `TESTED` · `VERIFIED` | `verification.{implementation,tests,documentation}` ∈ `verified\|partial\|pending`, mais `completion` `declared`/`accepted` |
| `DIVERGED` | `analysis/divergences.yaml` — arquivo, não estado |
| `BLOCKED` | **não existe**: bloqueio é informação de gestão, não estado de evidência. Um requisito bloqueado é `PLANNED` ou `IN_PROGRESS` com nota |

**3. Qualidade de evidência vive em eixos paralelos** que nunca movem o
percentual: `completion`, `verification`, `evidence.knownness`, `confidence` e
Measurement Precision.

**4. `tracking:` sai do template.** Segurança e qualidade, se voltarem pelo
roadmap, voltam como **eixo separado** — jamais como dimensão do percentual.

## Consequências

- Perde-se a leitura "a documentação está em 82%". Quem quiser isso lê
  `precision.documentation`, que mede a **medição**, não o progresso.
- As três verdades do desenho original (`Intended ✓ Implemented ✓ Verified ✗ →
  PARTIALLY VERIFIED`) passam a se ler como `status: COMPLETED` +
  `completion: declared`. A informação sobrevive; só não vira um quarto número.
- Nenhuma chave de configuração promete dimensão que o protocolo não calcula.
- `verification` ganha verbete no glossário — era o único campo do ledger sem
  definição em português.

## Alternativas descartadas

- **PROJECT HEALTH ponderado** — mistura evidência com progresso, e cada peso
  é uma opinião não auditável. Pior: torna o número negociável via config.
- **Sete estados** — `IMPLEMENTED`, `TESTED` e `VERIFIED` não são posições numa
  régua; são três verdades simultâneas sobre o mesmo requisito. Enfileirá-las
  obriga a inventar percentuais intermediários, exatamente o que o ADR-0001
  fechou.
- **`BLOCKED` como status** — bloqueio não tem teste observável no diff. É
  estado do mundo, não do código.
- **Manter `tracking:` "reservado para o futuro"** — config morta distribuída
  para dentro de outros repositórios é promessa não cumprida. É o defeito que
  esta skill existe para auditar.
