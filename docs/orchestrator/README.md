# 🏗️ Orquestração de Fluxos (Airflow) - Squad 3

Este diretório centraliza a inteligência de agendamento e execução do ecossistema de dados. O orquestrador é responsável por garantir que o código esteja atualizado, o ambiente configurado e os dados processados na ordem correta.

---

## 🛠️ Detalhamento das DAGs e Tasks

### 1. `core_bootstrap`
**Objetivo:** Preparação do terreno. Antes de qualquer dado ser processado, esta DAG garante que o ambiente de execução (Worker) seja um espelho fiel do repositório de código.

* **sync_core_repository**: Realiza o `fetch` e `reset --hard` do repositório Core. Vantagem: Elimina conflitos de arquivos locais e garante que estamos rodando a versão `main` oficial.
* **setup_core_environment**: Injeta dinamicamente as credenciais da OCI e limites de hardware (DuckDB) no arquivo `.env`. Vantagem: Segurança e performance calibrada.
* **install_core_dependencies**: Roda o `pip install`. Vantagem: Garante que novas libs adicionadas pelos desenvolvedores estejam disponíveis no runtime.
* **set_pipeline_permissions**: Ajusta permissões de execução. Vantagem: Evita falhas de "Permission Denied" no disparo dos scripts bash.

---

### 2. `ingestion_bridge`
**Objetivo:** O "Ponteiro" de dados. Sincroniza a origem com o destino de processamento.

* **sync_raw_layer**: Move dados do MinIO (VPS) para o Object Storage (OCI).
* **Vantagens**: Desacopla a infraestrutura local da nuvem. Ao isolar a ingestão, o pipeline principal não precisa lidar com protocolos de conexão instáveis da origem; ele foca apenas em transformar o que já está no OCI.

---

### 3. `core_pipeline`
**Objetivo:** O motor principal. Executa a lógica de negócio e as transformações de dados.

* **execute_unified_pipeline**: Aciona o script `bin/run_pipeline.sh`.
* **Vantagens**: Encapsulamento. Se a lógica de transformação mudar dentro do repositório Core, a DAG não precisa ser alterada. Ela apenas dá o comando de "ignição".

---

## 📅 Estratégia de Janelas de Execução (Schedules)

A arquitetura de horários foi desenhada para evitar concorrência de recursos e garantir a linearidade dos dados:

| DAG | Agendamento | Horário (UTC) | Papel na Cadeia |
| :--- | :--- | :--- | :--- |
| **core_bootstrap** | Semanal (Seg) | 03:00 | Atualiza o software e o ambiente. |
| **ingestion_bridge** | Mensal (Dia 1º) | 04:00 | Garante que os dados brutos novos chegaram ao OCI. |
| **core_pipeline** | Mensal (Dia 1º) | 06:00 | Processa os dados após o ambiente e os arquivos estarem prontos. |

---

## 🔄 Política de Retenção e Run IDs

Diferente de processos simples, cada execução do pipeline é rastreada por um **Run ID** exclusivo.

* **Isolamento por Run**: Cada execução gera uma linhagem de dados específica, permitindo identificar exatamente qual "safra" de processamento gerou determinado resultado nas camadas Bronze, Silver ou Gold.
* **Política de Retenção Automática**: Integrado ao `core_bootstrap`, o sistema respeita as variáveis de ambiente de retenção:
    * `BRONZE/SILVER/GOLD_MAX_RUNS=2`: O sistema mantém apenas as duas últimas execuções bem-sucedidas. 
* **Vantagem**: Isso evita o inchaço do Object Storage (OCI), reduzindo custos e mantendo apenas o histórico necessário para recuperação de desastres ou auditoria imediata.

---

> **🚨 Nota de Operações**: Qualquer falha na `core_bootstrap` deve ser tratada como prioridade máxima, pois ela é o requisito fundamental para a saúde das demais DAGs.

## 🌐 Painel de Observabilidade (Streamlit)

Para monitoramento preventivo e diagnóstico ágil, utilize nossa interface interativa de saúde de dados.

![Dashboard Squad 3](../images/data_observability/demo_painel.gif)
*GIF demonstrativo: Navegação entre relatórios.*

🌐 **Link do Painel Vivo:** [Painel de Observabilidade (Streamlit)](http://137.131.205.67:8501/)