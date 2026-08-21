# ADR-0003 — Hook não chama modelo; debounce de 10 minutos

**Status:** Aceito · v0.1, revisado na v0.2

## Contexto

O gatilho natural para reavaliar progresso é o commit. Mas um agente de código
commita em rajada: dez, vinte commits em poucos minutos. Chamar um modelo em
cada `post-commit` significaria custo multiplicado por vinte, latência dentro do
fluxo de commit do desenvolvedor, e vinte snapshots quase idênticos.

## Decisão

Separar **captura de evento** de **análise**, em três processos:

| Processo | Faz | Chama modelo? |
|---|---|---|
| `post-commit` | grava `pending` e `last-commit-ts`; apaga `review-due` | não |
| `watch.sh` | espera `debounce_minutes` de silêncio; grava `review-due` | não |
| sessão do agente | vê `review-due` e roda `dashproject review` | **sim** |

Cada commit novo reinicia a janela. Um burst inteiro gera **um** review sobre
`BASE..HEAD`.

O bloco do hook é delimitado por `# >>> DASHPROJECT >>>` / `# <<< DASHPROJECT <<<`
e o instalador nunca substitui o corpo do hook fora dos marcadores.

## Consequências

- Custo por burst, não por commit.
- O hook não pode falhar de forma cara: são quatro comandos de shell.
- Nada acontece se ninguém abrir sessão do agente. O `review-due` fica pendurado
  aguardando — visível, mas inerte. É um trade-off consciente: o watcher não tem
  autoridade para gastar tokens.
- `review_notify` é um comando local (ex.: `notify-send`), nunca um gatilho de
  modelo.
- Convive com hooks existentes de outras ferramentas.

## Alternativas descartadas

- **Analisar em cada commit** — custo e latência inaceitáveis.
- **Analisar em `pre-push`** — perde o burst local de quem não dá push.
- **Daemon que invoca o modelo sozinho** — gasto de tokens sem supervisão
  humana; e credenciais de API num serviço systemd de longa duração.
