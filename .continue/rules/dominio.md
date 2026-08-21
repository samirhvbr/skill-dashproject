---
name: Regras de domínio do DASHPROJECT
alwaysApply: true
---

# Regras de domínio — invioláveis

Este repositório é a skill `skill-dashproject`, um auditor de progresso baseado
em evidências. Quatro regras valem em código, documentação e exemplos:

1. **Progresso é discreto.** Um requisito vale `0`, `50` ou `100` — nunca 63,
   70 ou 80. `PLANNED→0`, `IN_PROGRESS→50`, `COMPLETED→100`.

2. **`status` é a fonte da verdade.** Nunca persista um campo `progress` numa
   linha de requisito. Progresso é sempre recalculado a partir de `status`:
   `mean(derived(status))` sobre os requisitos com `withdrawn != true`.

3. **Atividade não é progresso.** Contagem de arquivos, LOC, churn e número de
   commits nunca são convertidos em percentual de projeto. Vivem no bloco
   `activity`, alimentados só por `git ls-files` e `git log`.

4. **Pretensão não é evidência.** `COMPLETED` declarado num commit é validado
   contra o diff. Recusado, o requisito volta ao status anterior e o motivo vai
   para `rejected_claims` — ele **não** permanece `COMPLETED`.

## Ao escrever exemplos

Todo exemplo numérico precisa fechar a conta:

```
(completed × 100 + in_progress × 50) / active
```

Um exemplo que não fecha ensina o agente a errar. Confira antes de commitar.

## Distinção que gera confusão

- **Este repositório** = o código-fonte da skill.
- `.dashproject/` = a saída do auditor **dentro de um projeto auditado**.

Não crie `.dashproject/` aqui.
