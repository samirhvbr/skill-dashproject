# Architecture Decision Records

Registro das decisões caras de reverter, com o contexto que as motivou.

| # | Decisão | Status |
|---|---|---|
| [0001](0001-progresso-discreto.md) | Progresso discreto 0/50/100 por requisito | Aceito |
| [0002](0002-status-como-fonte-da-verdade.md) | `status` é a fonte da verdade; `progress` é derivado | Aceito |
| [0003](0003-hook-sem-llm-e-debounce.md) | Hook não chama modelo; debounce de 10 minutos | Aceito |
| [0004](0004-atividade-separada-de-progresso.md) | Atividade do repositório é independente do progresso | Aceito |
| [0005](0005-idioma-hibrido.md) | Prompt em inglês, documentação humana em PT-BR | Aceito |

## Convenções

- Nome: `NNNN-titulo-em-kebab-case.md`, numeração sequencial, sem buracos.
- Status: `Proposto` · `Aceito` · `Substituído por ADR-NNNN`.
- Um ADR aceito **não é editado**. Mudou de ideia? Escreva o próximo e marque o
  anterior como substituído.
- Seções fixas: Contexto · Decisão · Consequências · Alternativas descartadas.
