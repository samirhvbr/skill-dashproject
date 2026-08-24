# ADR-0013 — A prova de `COMPLETED` não é só cenário: ArchUnit, fitness e perna de CI contam, com condição

**Status:** Aceito · v0.5.0 · emenda a [ADR-0002](0002-status-como-fonte-da-verdade.md) e ao `references/scoring.md`

## Contexto

O `scoring.md` desenha a evidência de `COMPLETED` como *"implementação que casa
com o requisito **e testes que a cobrem**"*, e na prática o auditor lia "teste"
como **cenário executável que NOMEIA o requisito**. É um corte bom: é sintático,
conferível, e não pede julgamento sobre o que uma prova prova.

O problema apareceu no primeiro projeto grande auditado (EOP, 214 requisitos) e
não foi o corte — foi a **inconsistência**. Três medições seguidas, entre 23 e
24/08/2026:

1. Dos cinco requisitos `unknown` não-fiscais, **quatro tinham prova no disco**
   por outra classe de artefato: uma regra de **ArchUnit** (`R18`), uma
   **fitness de arquitetura** (`FitnessDaAusenciaDaSessao`) e duas **pernas de
   CI** (checagens `S7`/`S5` do docs-lint). O auditor os deixou `PLANNED`.
2. Ao mesmo tempo, **seis linhas já eram `COMPLETED` com exatamente essas
   classes de prova** — `docs-lint S8` ×2, `docs-lint S7` ×2, `docs-lint S5`, e
   uma fitness da cadeia do razão.
3. O caso sem defesa possível: a **mesma** checagem `S7` prova *"nenhum evento
   carrega dado pessoal"* em três pacotes, e valia `COMPLETED` em dois
   (`REQ-144`, `REQ-210`) e `PLANNED` no terceiro (`REQ-188`).

Ou seja: o ledger **já lia** as três classes, sem dizer que lia. O defeito não
era cegueira — era a régua não estar escrita, então cada rodada decidia de novo.

## Decisão

**As três classes contam como prova de `COMPLETED`** — regra de ArchUnit,
fitness de arquitetura e perna de CI —, sob **uma condição de três partes**:

> A prova tem de ser **NOMEADA** (o ledger cita o artefato: classe, método ou
> código da checagem, não "há testes"), **EXISTENTE** (o artefato está no disco
> hoje) e **VERDE NO CI** (ela roda na esteira que o projeto declara, não numa
> lista de casos que ninguém executa).

O corte deixa de ser *"é cenário?"* e passa a ser *"é prova executável,
endereçável e executada?"* — que é a mesma exigência do cenário, sem privilegiar
o formato dele.

`completion` continua distinguindo o grau: prova das três classes com o
requisito nomeado dá `accepted`; implementação plausível sem prova nomeada
segue `declared`. **O 0/50/100 não muda** — nenhum estado novo nasce.

## Consequências

- **O que o número ganha:** ele para de subestimar de propósito. Um invariante
  provado por fitness passa a valer o que vale.
- **O que o número perde:** o corte sintático puro. Mitigado pela condição — as
  três partes são conferíveis por máquina (o artefato existe? é citado? a
  esteira o executa?), e é isso que impede "a fitness prova mesmo?" de virar
  julgamento a cada rodada.
- **O caso que a condição fecha, e ele é real:** no mesmo dia, um requisito do
  EOP (`REQ-140`) tinha a spec declarando uma *fitness de arquitetura* que
  **não existe no repositório**. Sem a parte "EXISTENTE", ele viraria
  `accepted` por uma prova imaginária. Com ela, fica `declared` e a divergência
  vai para `analysis/divergences.yaml`.
- **Contradição entre requisitos irmãos vira achado**, não silêncio: se o mesmo
  artefato prova A e não prova B, um dos dois está errado — e o auditor passa a
  dizer qual par diverge.

## Alternativas descartadas

- **Manter o corte "só cenário"**: perpetua um medidor que mente para baixo *e*
  a inconsistência dos seis casos que já contavam. Mede menos e não mede melhor.
- **Estado novo (`PROVEN_BY_FITNESS`, entre 50 e 100)**: quebra o eixo
  0/50/100, que é a espinha da skill inteira — e o grau já existe em
  `completion`.
- **Aceitar as três classes SEM condição**: devolve o julgamento à rodada. O
  `REQ-140` acima mostra o custo em menos de um dia.
