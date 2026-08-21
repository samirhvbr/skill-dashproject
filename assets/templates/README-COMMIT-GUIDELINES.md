## DASHPROJECT — Commit Guidelines

O progresso do projeto é medido por requisito (`REQ-NNN`). Cada requisito vale **0, 50 ou 100**. O commit deve declarar o que mudou.

### Formato

```
feat(REQ-102): implement boleto generation

Requirements:
- REQ-102: IN_PROGRESS
```

Quando o comportamento estiver feito:

```
feat(REQ-102): complete boleto generation

Requirements:
- REQ-102: COMPLETED
```

Vários requisitos no mesmo commit (só se forem do mesmo recorte):

```
feat(REQ-102,REQ-103): boleto generation and cancellation

Requirements:
- REQ-102: IN_PROGRESS
- REQ-103: IN_PROGRESS
```

### Tipos

- `feat` / `fix` — podem mudar o estado (0 → 50 → 100)
- `test` / `docs` — evidência extra; não substituem a declaração de estado
- `refactor` / `chore` — sem mudança de progresso, salvo se declararem um REQ
- `chore(dashproject)` — reservado ao auditor

### Regras

1. Um commit declara quais requisitos altera e o novo estado (`IN_PROGRESS` ou `COMPLETED`).
2. Não misture dezenas de requisitos não relacionados.
3. `COMPLETED` significa o comportamento daquele requisito, não “o módulo inteiro”.
4. O DASHPROJECT valida a declaração. Sem implementação plausível, o requisito não vai para 100.
