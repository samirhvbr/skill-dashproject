# ADR-0002 — `status` é a fonte da verdade; `progress` é derivado

**Status:** Aceito · v0.2

## Contexto

Na v0.1 o ledger guardava um campo `progress` ao lado de `status`. Bastava um
agente escrever `progress: 100` numa linha para inflar o número sem nenhuma
evidência — e os dois campos podiam divergir silenciosamente.

Há ainda um segundo problema: `COMPLETED` declarado num commit é uma
**pretensão**, não um fato. Aceitá-la sem olhar o diff transforma o auditor em
eco do implementador.

## Decisão

1. **Nunca** persistir `progress` numa linha de requisito. Ele é recalculado a
   partir de `status` em toda leitura.
2. `COMPLETED` recebe um segundo campo `completion`:

   | valor | implementação | testes | status final |
   |---|---|---|---|
   | `accepted` | plausível | presentes | `COMPLETED` (100) |
   | `declared` | plausível | ausentes | `COMPLETED` (100) |
   | `rejected` | não plausível | — | **status anterior** (0 ou 50) |

3. Pretensão recusada nunca permanece como `COMPLETED`. Vai para
   `rejected_claims` no snapshot, com o motivo.
4. O bootstrap é conservador: existência de arquivo não é conclusão. Sem
   evidência forte, `PLANNED` + `evidence.knownness: unknown`.

## Consequências

- Inflar o progresso exige editar `status` no ledger — o que é fora do
  protocolo e visível no diff do próprio `.dashproject/`.
- `declared` continua valendo 100. A distinção para `accepted` vive na
  precision e na `confidence`, não no percentual. Se testes ausentes derrubassem
  o percentual, o número deixaria de responder "o comportamento existe?".
- Um commit `test(REQ-102)` posterior promove `declared` → `accepted` sem tocar
  no percentual.
- O bootstrap conservador **subestima** o projeto de propósito. Por isso o
  snapshot inicial grava `baseline_confidence`.

## Alternativas descartadas

- **Confiar na declaração do commit** — o implementador é parte interessada.
- **`declared` valer 75** — reintroduz o valor intermediário do ADR-0001 e
  mistura dois eixos (o comportamento existe × a evidência é boa).
