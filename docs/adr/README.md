# Architecture Decision Records

Registro das decisões caras de reverter, com o contexto que as motivou.

| # | Decisão | Status |
|---|---|---|
| [0001](0001-progresso-discreto.md) | Progresso discreto 0/50/100 por requisito | Aceito |
| [0002](0002-status-como-fonte-da-verdade.md) | `status` é a fonte da verdade; `progress` é derivado | Aceito |
| [0003](0003-hook-sem-llm-e-debounce.md) | Hook não chama modelo; debounce de 10 minutos | Aceito |
| [0004](0004-atividade-separada-de-progresso.md) | Atividade do repositório é independente do progresso | Aceito |
| [0005](0005-idioma-hibrido.md) | Prompt em inglês, documentação humana em PT-BR | Aceito |
| [0006](0006-declaracao-de-status-no-commit.md) | Default no subject; `COMPLETED` só explícito; verbo não é lido | Aceito |
| [0007](0007-um-numero-e-tres-estados.md) | Um número de progresso, três estados de requisito | Aceito |
| [0008](0008-timeline-retrospectiva.md) | Timeline retrospectiva; sem previsão de conclusão | Aceito |
| [0009](0009-tres-saidas-do-mesmo-snapshot.md) | YAML/Markdown/HTML projetam o mesmo snapshot | Aceito |
| [0010](0010-subject-livre-e-bloco-requirements.md) | Subject livre; o bloco `Requirements:` é a única sintaxe obrigatória | Aceito |
| [0011](0011-modelo-e-esforco-no-frontmatter.md) | Modelo e esforço no frontmatter; escalonamento é hand-off, não automático | Aceito |
| [0012](0012-escalonamento-por-esforco.md) | Escalonamento muda o **esforço**, não o modelo (emenda ao 0011 §3) | Aceito |
| [0013](0013-prova-que-nao-e-cenario.md) | A prova de `COMPLETED` **não é só cenário**: ArchUnit, fitness e perna de CI contam, sob a condição de serem **nomeada, existente e verde no CI** (emenda ao 0002 e ao `scoring.md`) | Aceito |

## Convenções

- Nome: `NNNN-titulo-em-kebab-case.md`, numeração sequencial, sem buracos.
- Status: `Proposto` · `Aceito` · `Substituído por ADR-NNNN`.
- Um ADR aceito **não é editado**. Mudou de ideia? Escreva o próximo e marque o
  anterior como substituído.
- Seções fixas: Contexto · Decisão · Consequências · Alternativas descartadas.
