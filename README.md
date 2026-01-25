![header](docs/images/main/header_main.png)

Repositório de desenvolvimento, documentação e implementação técnica da camada operacional da solução integrada de dados para o Hackathon da Pod Academy - Squad 3.

> Este repositório centraliza o provisionamento de infraestrutura como código (IaC), a orquestração dos pipelines e os mecanismos de ingestão e execução em nuvem, viabilizando a operação da arquitetura em ambiente Oracle Cloud Infrastructure (OCI).

### 🔗 Ecossistema Squad 3
* **Repositório 1 de 2 (Core):** [hackathon-pod-squad3-core](https://github.com/rafa-trindade/hackathon-pod-squad3-core) - _Engine de processamento e Governança de Dados (arquitetura medalhão)._
* **Repositório 2 de 2 (Ops):** [hackathon-pod-squad3-ops](https://github.com/rafa-trindade/hackathon-pod-squad3-ops) - _Infraestrutura (IaC), Orquestração e Ingestão de Dados (Cloud Readiness)._

> 🔐 O Core define **o que** a arquitetura executa.  
> ⚙️ O Ops define **como e onde** ela é executada.

---

## 📖 Navegação Técnica (Documentação)

Para uma compreensão aprofundada de cada camada da operação, explore os guias detalhados abaixo:

* **🏗️ [Infraestrutura Cloud](docs/infrastructure/architecture.md):** Detalhamento da rede, segurança (IAM/Instance Principal) e hardware.
* **📊 [Arquitetura de Dados](docs/data_architecture/README.md):** Fluxo de ingestão, camadas Medallion e governança no DuckDB.
* **🚀 [Guia de Deployment](docs/setup/deployment.md):** Passo a passo para provisionamento via Terraform e ativação do ambiente.

---

## 🛠️ Stack Tecnológica & Hardware Strategy

A arquitetura de processamento foi desenhada em duas fases para otimização de performance e custos:

### **Fase 1: Sandbox & Testes (Atual)**
* **Shape:** `VM.Standard.A1.Flex` (ARM Ampere)
* **Recursos:** 4 OCPUs | 24GB RAM
* **Custo:** Always Free Tier (OCI)

### **Fase 2: Produção Oficial (Enterprise)**
* **Shape:** `VM.Standard.E4.Flex` (AMD EPYC™)
* **Recursos:** 8 OCPUs | 64GB RAM (Escalável)
* **Objetivo:** Alta performance para o motor DuckDB e paralelismo total de DAGs.

---

## 📂 Localização dos Projetos na VM (Cloud Path)

Após o provisionamento e o bootstrap via `cloud-init`, os projetos são organizados para garantir a separação entre orquestração e processamento:

* **📍 Raiz da Aplicação:** `/home/opc/app/`
* **⚙️ Camada Ops (Orquestração):** `/home/opc/app/hackathon-pod-squad3-ops/`
    * _Residência de Dockerfiles, Airflow DAGs e scripts de ingestão._
* **🔐 Camada Core (Processamento):** `/home/opc/app/hackathon-pod-squad3-core/`
    * _Residência do motor DuckDB e regras de governança (Medallion)._
