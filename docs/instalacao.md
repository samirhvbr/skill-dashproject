# Instalação

## Requisitos

| Item | Versão | Uso |
|---|---|---|
| `git` | 2.20+ | Fonte de toda a atividade e do protocolo de commit |
| `python3` | 3.9+ | `scripts/collect-activity.py` (usa `from __future__ import annotations`) |
| `bash` | 4+ | Hook, watcher e instalador |
| `zip` | qualquer | Apenas para `scripts/build-release.sh` |

Nenhuma dependência de `npm`, Docker ou banco de dados. O dashboard é HTML
estático — abre com duplo clique.

## 1. Instalar a skill no agente

Copie este repositório para a pasta de skills do agente:

```bash
git clone https://github.com/samirhvbr/skill-dashproject.git \
  ~/.claude/skills/skill-dashproject
```

Confirme que o agente enxerga a skill pedindo `dashproject status` num
repositório qualquer.

## 2. Bootstrap no projeto auditado

Dentro do repositório do produto:

```
dashproject init
```

Isso cria `.dashproject/`, escreve o mapa de requisitos a partir da
documentação existente e **acrescenta** (não reescreve) a seção de commit ao
`README.md` do projeto.

O bootstrap é conservador de propósito: arquivo que apenas *parece* o requisito
não vira `COMPLETED`. Veja [adr/0002-status-como-fonte-da-verdade.md](adr/0002-status-como-fonte-da-verdade.md).

## 3. Instalar o hook de commit

```bash
scripts/install-git-hook.sh
```

O instalador insere um bloco delimitado por marcadores:

```
# >>> DASHPROJECT >>>
...
# <<< DASHPROJECT <<<
```

Se já existir um `post-commit`, o corpo fora dos marcadores é preservado.
Rodar de novo **atualiza** o bloco em vez de duplicá-lo.

O hook nunca chama um modelo. Ele só grava `.dashproject/pending` e o timestamp.

## 4. Watcher de debounce (opcional)

```bash
dashproject watch          # em foreground
scripts/watch.sh --once    # avalia uma vez e sai
```

O watcher espera `debounce_minutes` (padrão 10) sem commits novos e então grava
`.dashproject/review-due`. Também não chama modelo.

### Como serviço de usuário no Debian

```bash
cp assets/templates/dashproject-watch.service \
   ~/.config/systemd/user/dashproject-watch.service
# edite WorkingDirectory e ExecStart trocando /srv/CHANGE_ME
systemctl --user daemon-reload
systemctl --user enable --now dashproject-watch
```

## 5. Verificar

```bash
scripts/pending-ready.sh   # 0 = review devido, 2 = ainda no debounce
scripts/check-docs.sh      # consistência da documentação deste repositório
```
