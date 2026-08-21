# Documentação — DASHPROJECT

`docs/` é a documentação **humana** do repositório da skill. Não confundir com
`.dashproject/`, que é a saída do auditor dentro de um projeto auditado.

| Página | Quando ler |
|---|---|
| [instalacao.md](instalacao.md) | Instalar a skill, o hook e o watcher |
| [uso.md](uso.md) | Comandos do dia a dia e o ciclo de trabalho |
| [arquitetura.md](arquitetura.md) | Como as peças se encaixam e por quê |
| [padrao-documentacao.md](padrao-documentacao.md) | O padrão que este repositório segue |
| [glossario.md](glossario.md) | Vocabulário: progress, precision, completion, knownness |
| [troubleshooting.md](troubleshooting.md) | Quando o hook, o watch ou o review não fazem o esperado |
| [adr/](adr/) | Decisões de arquitetura e o motivo delas |

## Mapa mental em três linhas

1. Requisito é a menor unidade e vale **0, 50 ou 100** — nunca 63.
2. `status` é a fonte da verdade; `progress` é **derivado**, nunca gravado.
3. Atividade do repositório (arquivos, churn, commits) **não é** progresso.

## Para o agente, não para o humano

- [`SKILL.md`](../SKILL.md) — o protocolo do auditor (inglês)
- [`references/`](../references/) — material carregado sob demanda (inglês)
- [`CLAUDE.md`](../CLAUDE.md) — contexto operacional deste repositório
