# ADR-0012 — O escalonamento muda o esforço, não o modelo (emenda ao ADR-0011 §3)

**Status:** Aceito · v0.4.2 · emenda a [ADR-0011](0011-modelo-e-esforco-no-frontmatter.md) §3

## Contexto

O [ADR-0011](0011-modelo-e-esforco-no-frontmatter.md) fez o trabalho difícil:
tirou `analysis.model` da condição de comentário em YAML, pôs `model: sonnet` +
`effort: medium` no frontmatter do `SKILL.md`, e transformou o escalonamento em
hand-off explícito. O que ele **não** revisitou foi o eixo do escalonamento, que
vinha intacto da v0.1:

```yaml
escalate:
  bootstrap: opus
  low_confidence: opus
  release: opus
  major_divergence: opus
```

Esse desenho é de quando **modelo era o único eixo disponível**. Quando a única
alavanca é trocar de modelo, "mais difícil" e "modelo maior" viram a mesma
frase. Hoje não são: `effort` é um eixo próprio, e o Sonnet 5 em `high` não é o
mesmo trabalho que o Sonnet 5 em `medium`.

Manter os dois eixos tem custo concreto, e ele é maior do que parece:

- **Dois modelos na casa para uma decisão só.** O ADR-0011 §2 acabou de eliminar
  a divergência de string entre `SKILL.md` e `config.yaml`; um `escalate` que
  nomeia um segundo modelo reabre a mesma classe de divergência num campo que o
  `check-docs.sh` não cobria.
- **O hand-off fica mais caro do que precisa.** Trocar de modelo obriga o
  operador a trocar a sessão inteira. Subir o esforço é a mesma skill, o mesmo
  contexto, o mesmo modelo.
- **`deep` nunca esteve no `escalate`.** O `references/cycles.md` dizia
  "bootstrap / deep / release → opus" e o `config.yaml` só listava três dos
  quatro. A condição existia na prosa e não no contrato — a mesma classe de
  defeito "declarado ≠ imposto" que o ADR-0011 fechou.

## Decisão

1. **`escalate` passa a declarar nível de esforço, nunca nome de modelo.**
   Valores válidos: `low` · `medium` · `high` · `xhigh` · `max`.
2. **Um modelo só**: `sonnet` no caminho rotineiro e no escalado. O que muda
   entre eles é o orçamento de raciocínio.
3. **`bootstrap` sobe para `xhigh`; o resto para `high`.** Bootstrap é o único
   ciclo que escreve o mapa inteiro de requisitos e o baseline — o número que
   todo mundo lê depois. O ADR-0011 já tinha registrado essa assimetria nas
   consequências ("um mapa escrito no modelo errado é caro de desfazer"); aqui
   ela vira valor no contrato em vez de comentário.
4. **`deep` entra no `escalate`**, fechando o vão entre a prosa do `cycles.md` e
   o schema.
5. **`scripts/check-docs.sh` reprova valor de `escalate` que não seja um nível de
   esforço válido** — inclusive nome de modelo. É o que impede este ADR de virar
   comentário em YAML pela mesma porta que o ADR-0011 fechou.

O §3 do ADR-0011 continua valendo **inteiro** na parte que importa: escalonar
não é automático. O auditor para, nomeia a condição e o requisito, e pede que o
operador rode de novo — agora sob outro **esforço**, não sob outro modelo.

## Consequências

- Custo previsível: um modelo, cinco níveis. Some a pergunta "qual modelo isto
  rodou?" do orçamento e fica só "com quanto esforço?".
- O hand-off do bootstrap fica mais barato de atender — mesma sessão, mesmo
  modelo, um parâmetro.
- ⛔ **Não medido:** se Sonnet 5 em `xhigh` classifica um bootstrap tão bem
  quanto Opus 5 em `medium` classificaria. Nenhum bootstrap real rodou ainda —
  o do EOP está adiado por decisão. Esta é uma escolha de desenho com o eixo
  certo, não um resultado. O primeiro bootstrap é a medição, e ele pode reabrir
  este ADR.
- O `latest.yaml` continua gravando o modelo **que rodou** (ADR-0011 §4). Passa a
  gravar também o `effort`, pela mesma razão: declaração que nada observa não é
  controle.

## Alternativas descartadas

- **Manter Opus no `escalate`** (status quo do ADR-0011). Descartada pelos três
  custos acima — e porque o eixo estava herdado, não escolhido: ninguém decidiu
  "modelo" contra "esforço", porque quando o `escalate` nasceu não havia
  escolha.
- **Os dois eixos: Opus 5 + `effort` declarado.** Expressa mais, e é o que um
  schema completo permitiria. Descartada por não haver, hoje, uma condição em
  que se saiba dizer que Opus/medium ganha de Sonnet/xhigh — schema que oferece
  uma escolha que ninguém sabe fazer produz configuração por palpite.
- **`max` no bootstrap em vez de `xhigh`.** Descartada por falta de medição: sem
  um bootstrap real rodado, escolher o teto é gastar o máximo por precaução, e
  `xhigh` já é uma mudança grande de orçamento sobre `medium`.
- **Deixar `escalate` livre (modelo ou esforço, o que o operador escrever).**
  Descartada: campo que aceita dois vocabulários não é validável, e não
  validável foi exatamente como `analysis.model` virou comentário.
