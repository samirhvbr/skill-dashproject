---
description: Valida a consistência da documentação e dos scripts deste repositório
---

Rode a bateria de verificação deste repositório e reporte apenas o que falhou:

```bash
scripts/check-docs.sh
bash -n scripts/*.sh
python3 -m py_compile scripts/collect-activity.py
```

Depois confira manualmente o que o script não cobre:

1. Todo exemplo numérico na documentação fecha a conta?
   Em especial `(completed×100 + in_progress×50) / active`.
2. A árvore de arquivos no `README.md` bate com a árvore real?
3. Há regra do domínio violada em algum texto novo — progresso fora de
   0/50/100, campo `progress` persistido, ou atividade virando percentual?
4. Arquivo novo respeita o idioma do [ADR-0005](../../docs/adr/0005-idioma-hibrido.md)?

Não corrija nada sem antes listar os achados.
