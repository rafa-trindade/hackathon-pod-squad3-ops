## PADRÃO DE COMMITS – PROJETO SQUAD3

Este projeto utiliza um padrão de commits inspirado em Conventional Commits,
adaptado para engenharia de dados, pipelines, qualidade e performance.

Objetivos:
- Histórico de commits legível
- Facilidade para CI/CD, changelog e manutenção

---

### ESTRUTURA DO COMMIT

`<tipo>(<escopo>): <mensagem>`

Exemplo:
```bash
git commit -m "perf(config): melhorias de performance e configuração"
```

---

### TIPOS DE COMMIT

| Tipo | Descrição |
| :--- | :--- |
| **docs** | Usado exclusivamente para documentação. Não altera código ou comportamento. |
| **perf** | Melhorias de performance sem alterar regra de negócio. |
| **chore** | Tarefas operacionais, organização, limpeza, padronização. |
| **refactor** | Refatoração de código sem mudança de comportamento. |
| **fix** | Correção de bugs. |
| **feat** | Nova funcionalidade ou novo comportamento. |

---

### REGRAS RÁPIDAS

- **Scripts operacionais** -> `chore`
- **Melhoria interna** -> `refactor` ou `perf`
- **Impacta comportamento** -> `feat` ou `fix`
- **Documentação** -> `docs`
- Sempre usar **verbo no presente**.
- Commits **pequenos e objetivos**.

---

### ESCOPOS E EXEMPLOS POR DIRETÓRIO

#### **INFRA** `terraform/`
Escopo: `infra`

```bash
git commit -m "feat(infra): provisiona bucket lake-squad3 via terraform"
```

```bash
git commit -m "fix(infra): corrige política de acesso IAM para dynamic group"
```

```bash
git commit -m "perf(infra): ajusta shape da instância para vm.standard.e4.flex"
```

---

#### **ORQUESTRAÇÃO & DOCKER** `orchestrator/`
Escopo: `ops`

```bash
git commit -m "feat(ops): adiciona stack do airflow via docker-compose"
```

```bash
git commit -m "chore(ops): atualiza variáveis de ambiente no .env"
```

```bash
git commit -m "fix(ops): ajusta montagem de volumes para dags do core"
```

---

#### **INGESTÃO & TRANSIÇÃO** `ingestion/`
Escopo: `bridge`

```bash
git commit -m "feat(bridge): implementa script minio_to_oci para fase 3"
```

```bash
git commit -m "perf(bridge): otimiza replicação de dados raw para oci"
```

```bash
git commit -m "fix(ops): ajusta montagem de volumes para dags do core"
```

---

#### **DOCUMENTAÇÃO** `docs/`
Escopo: `docs`

```bash
git commit -m "docs(docs): atualização da documentação"
```

```bash
git commit -m "docs(docs): adiciona data dictionary"
```

```bash
git commit -m "docs(docs): atualiza documentação de data quality"
```

---

### O QUE NÃO USAR

- Tipos não padronizados: *att, update, misc*
- Commits genéricos: *update, ajustes, fix bug*
- Misturar documentação e código no mesmo commit