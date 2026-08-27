## DASHPROJECT — Commit Guidelines

O progresso do projeto é medido por requisito (`REQ-NNN`). Cada requisito vale **0, 50 ou 100**. O commit deve declarar o que mudou.

### Formato

Para **começar** um requisito, o subject basta:

```
feat(REQ-102): boleto generation
```

Um `REQ-NNN` no subject de um `feat`/`fix`, sem corpo, já significa
`IN_PROGRESS`. Declarar explicitamente também vale:

```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

Quando o comportamento estiver feito, o corpo é **obrigatório**:

```
feat(REQ-102): complete boleto generation

Requirements:
- REQ-102: COMPLETED
```

> A palavra `complete` no subject é decorativa. O que muda o estado é o bloco
> `Requirements:`. O DASHPROJECT não lê o verbo — nem `complete`, nem
> `conclui`, nem `finaliza`, nem `fecha`.

Vários requisitos no mesmo commit (só se forem do mesmo recorte):

```
feat(REQ-102,REQ-103): boleto generation and cancellation

Requirements:
- REQ-102: IN_PROGRESS
- REQ-103: IN_PROGRESS
```

### Se este projeto tem padrão próprio de commit

O subject acima é conveniência, **não** exigência. Projeto com padrão próprio
mantém o padrão — o bloco `Requirements:` no corpo é declaração completa:

```
1.63.3 - fecha a duplicata da colheita automatica

Requirements:
- REQ-000: COMPLETED
```

> **`REQ-000` no exemplo é deliberado: ele nunca existe.** Os IDs começam em
> `REQ-001`, então nenhum requisito real pode ser declarado por engano de quem
> copiar o bloco. Antes daqui o exemplo usava `REQ-014` — e no primeiro
> repositório que rodou o bootstrap esse ID passou a existir de verdade
> (`accounting/F6`, num módulo de dinheiro). Exemplo que aponta para artefato
> real deixa de ser exemplo no dia em que o artefato nasce.

Vale para os repositórios da casa, cujo padrão é `X.Y.Z - descrição em
português` e que **proíbem** Conventional Commits. Sem type no subject, o estado
declarado no bloco é que manda.

### Tipos

- `feat` / `fix` — podem mudar o estado (0 → 50 → 100)
- `test` / `docs` — evidência extra; não substituem a declaração de estado
- `refactor` / `chore` — sem mudança de progresso, salvo se declararem um REQ
- `chore(dashproject)` — reservado ao auditor: é o assunto com que ele commita o
  próprio snapshot (`.dashproject/`, sem push). Não use esse prefixo no seu
  trabalho: ele é ignorado pela auditoria, e o que você declarar ali some

### Regras

1. Um commit cita os requisitos que altera. Para `COMPLETED`, declara o estado
   no corpo — começar é barato de declarar, concluir não é.
2. Não misture dezenas de requisitos não relacionados.
3. `COMPLETED` significa o comportamento daquele requisito, não “o módulo inteiro”.
4. O DASHPROJECT valida a declaração. Sem implementação plausível, o requisito não vai para 100.
