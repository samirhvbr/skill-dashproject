# ADR-0005 — Prompt em inglês, documentação humana em PT-BR

**Status:** Aceito · v0.3

## Contexto

Até a v0.2 o idioma era acidental: `README.md` e os templates em PT-BR,
`SKILL.md` e `references/` em inglês, sem nenhuma regra escrita. O resultado é
que cada arquivo novo era um sorteio, e revisar ficava desconfortável.

Dois usos muito diferentes convivem no mesmo repositório: arquivos que são
**prompt** (o modelo carrega e segue) e arquivos que são **documentação**
(pessoas leem).

## Decisão

Adotar o híbrido, agora explícito e documentado em
[padrao-documentacao.md](../padrao-documentacao.md#3-idioma):

| Alvo | Idioma |
|---|---|
| `SKILL.md`, `references/**` | Inglês |
| `README.md`, `docs/**`, `CONTRIBUTING.md`, `CHANGELOG.md` | PT-BR |
| `CLAUDE.md`, `.claude/**`, `.continue/**` | PT-BR |
| Código, nomes de arquivo, IDs, chaves YAML/JSON | Inglês |

Nunca misturar os dois idiomas dentro do mesmo arquivo.

## Consequências

- O material que entra em contexto a cada invocação fica em inglês — mais
  estável para o modelo seguir e mais econômico em tokens.
- O time lê arquitetura, instalação e uso em português.
- O custo é a duplicação conceitual: o protocolo de commit existe em inglês em
  `references/commit-protocol.md` e em português em `docs/uso.md` e no template
  de guidelines. Aceito conscientemente — são públicos diferentes. Quando o
  protocolo mudar, os três precisam mudar juntos.
- Os templates de `assets/templates/` que acabam sendo lidos por pessoas do
  projeto auditado (`README-COMMIT-GUIDELINES.md` e `README.md`) ficam em PT-BR:
  quem lê é o time do produto, não o modelo.

## Alternativas descartadas

- **Tudo em inglês** — barreira desnecessária para o time.
- **Tudo em PT-BR** — traduzir `SKILL.md` e `references/` significaria carregar
  prompt em português em toda invocação, com ganho zero para o leitor humano
  (o agente não se importa) e risco de deriva na instrução.
