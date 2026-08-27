# ADR-0014 — O auditor commita o próprio snapshot e devolve a árvore limpa

**Status:** Aceito · v0.5.1

## Contexto

O DASHPROJECT escrevia em `.dashproject/` e ia embora. Quem commitasse aquele
diretório depois era problema de outro: o humano, o agente principal, ou — no caso
que motivou este ADR — a skill **COMMITTER**, que roda por cron e commita a árvore
suja de todo repositório com marcador `.committer.yml`.

Achado no EOP em 22/08/2026, onde as duas skills convivem e `.dashproject/` é
versionado (o trabalho acontece em **duas estações**, e estado que fica fora do git
não atravessa). O ciclo era:

1. commit real → o hook `post-commit` escreve `.dashproject/pending` e
   `last-commit-ts` **logo depois do commit** → a árvore fica suja no instante
   seguinte, sem ninguém trabalhar;
2. o COMMITTER acorda, vê sujeira, empacota e commita;
3. esse commit **não** começa com `chore(dashproject)`, então o hook o trata como
   trabalho novo, grava `pending` outra vez → volta ao passo 2.

Uma volta por disparo de cron, indefinidamente, com a máquina parada. E como não
havia entrada de changelog nova, cada volta caía no fallback com modelo do
COMMITTER — que a trava de versão reutilizada de lá recusava. Custo recorrente,
zero commits produzidos.

O gatilho da outra skill não é o commit: é a **árvore suja**. Um auditor que escreve
arquivos e não os fecha não é neutro — ele terceiriza o próprio commit para quem
estiver passando.

## Decisão

O `review` (e o `bootstrap`) termina rodando
[`scripts/commit-snapshot.sh`](../../scripts/commit-snapshot.sh), que commita
`.dashproject/` e **só** ele:

- **Pathspec, nunca `-A`.** `git add -- .dashproject` seguido de
  `git commit -- .dashproject`: trabalho em andamento do implementador não entra, e
  o que ele já tinha staged continua staged.
- **Assunto `chore(dashproject): …`** — o mesmo prefixo que o hook já ignorava desde
  o [ADR-0003](0003-hook-sem-llm-e-debounce.md) e que o próprio auditor pula ao ler
  `BASE..HEAD`. É o que impede a revisão de se rearmar sozinha.
- **Nunca pusha.** Publicar é decisão de quem opera o repositório, não do observador.
- **Corpo sem bloco `Requirements:`.** Este commit não declara requisito nenhum, e o
  parser leria se declarasse.
- `analysis.auto_commit: true` no `config.yaml` é o default; `false` é o opt-out
  para quem quer revisar o snapshot antes que ele entre na história — e aí a árvore
  fica suja **de propósito**, com a razão impressa.

Do outro lado, o COMMITTER ganhou `skip_paths` no marcador (ADR-011 de lá), que tira
`.dashproject/` do stage dele. As duas metades resolvem coisas diferentes e ambas
são necessárias: `auto_commit` fecha a árvore **depois** da revisão; `skip_paths`
cobre a janela entre o commit real e a revisão (10 minutos de debounce) e o caso em
que a revisão não roda.

## Consequências

- A regra de isolamento do `SKILL.md` fica mais forte, não mais fraca: o auditor
  escreve **e commita** só `.dashproject/`. Antes ele escrevia ali e o commit
  daquilo saía com o nome de outro.
- O histórico do projeto auditado ganha um commit por revisão. É ruído aceito e
  filtrável (`git log --invert-grep --grep='^chore(dashproject)'`) — e o alternativo
  era o mesmo commit saindo sem autoria clara.
- O snapshot fica **local** até alguém pushar. Numa topologia de duas estações, isso
  significa que a medição só atravessa com push manual — igual ao resto do trabalho
  daquele repositório.
- Se o commit falhar (hook `pre-commit` do projeto recusando, por exemplo), o
  snapshot fica sujo e **visível** no `git status`. Falha silenciosa seria pior.

## Alternativas descartadas

- **Tirar `pending`/`last-commit-ts`/`review-due` do git.** Cortaria o combustível
  do loop na raiz, já que esses três são cursor de máquina local e não medição. Foi
  recusada por decisão explícita do Samir em 22/08/2026: no EOP vale "tudo se
  versiona, exceto segredo" (ADR-086 de lá), e a exceção nova abriria precedente
  para cada skill decidir o que não atravessa entre as estações.
- **Resolver só no COMMITTER.** `skip_paths` sozinho impede o loop, mas deixa
  `.dashproject/` sujo para sempre em repositório nenhum-dono — e o auditor
  continuaria dependendo da boa vontade alheia para virar história.
- **O auditor pushar também.** Publicar sem revisão é exatamente o que o `.committer.yml`
  do EOP desligou por escrito em 18/08/2026, depois de um commit automático publicado
  ter introduzido defeito. Não se reabre essa porta por conveniência de dashboard.
