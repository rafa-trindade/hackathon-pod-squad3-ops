# 🏗️ Infraestrutura como Código (Terraform) - Squad 3

Este documento descreve a arquitetura de nuvem da **Squad 3** na **Oracle Cloud Infrastructure (OCI)**. O provisionamento é totalmente automatizado via Terraform, garantindo um ambiente escalável, seguro e reprodutível.

---

## ☁️ Desenho da Solução

Nossa infraestrutura foi desenhada seguindo o princípio de desacoplamento entre **Compute** (Processamento) e **Storage** (Armazenamento), permitindo escalabilidade independente.

### 1. Rede e Segurança (Networking)
* **Localização:** Definido no arquivo `terraform/network.tf`.
* **VCN:** Rede virtual privada dedicada (`squad3-vcn`) com bloco CIDR `10.0.0.0/16`.
* **Firewall (Security List):** - Porta **22**: Acesso administrativo via SSH.
    - Porta **8080**: Interface web do Apache Airflow.
* **Saída para Internet:** Internet Gateway configurado para permitir atualizações de sistema e download de bibliotecas Python/Docker.

---

### 2. Motor de Processamento (Ops Engine)
* **Localização:** Definido no arquivo `terraform/compute.tf`.
* **Hardware:** Instância **ARM Ampere (A1.Flex)** com **4 OCPUs** e **24GB de RAM**.
* **Storage Local:** Boot volume de **150GB** (SSD) para suportar picos de processamento do DuckDB (cache em disco).
* **Bootstrap:** O arquivo `terraform/scripts/cloud-init.sh` automatiza a instalação do Docker e Docker Compose no primeiro boot da máquina.

---

### 3. Data Lakehouse (OCI Object Storage)
* **Localização:** Definido no arquivo `terraform/storage.tf`.
* **Storage:** Bucket `lake-squad3` configurado como **Standard Tier** para baixa latência.
* **Organização:** Estruturado para suportar a arquitetura Medallion (Bronze, Silver e Gold).


## 🔐 Identidade e Governança (IAM)

A segurança da Squad 3 é baseada no princípio do privilégio mínimo.

### Instance Principal (Automação)
* **Localização:** Definido no arquivo `terraform/iam.tf`.
* **Estratégia:** Utilizamos **Dynamic Groups**. A VM do Airflow tem permissão nata para gerenciar objetos no Bucket via políticas de IAM. Isso elimina a necessidade de armazenar chaves de acesso (`AWS_ACCESS_KEY`) dentro do código ou do servidor.

---

### Gestão de Membros (Acessos Humanos)
* **Engenharia de Dados (`squad3-eng-group`):** Acesso administrativo ao compartimento (Rafael, Fred e Ronaldo).
* **Analytics/Cientistas (`squad3-analytics-group`):** Acesso restrito de leitura ao Data Lake (Lucas, Carlos, Gabriel, Lazza, Gustavo e Michele).


## 📂 Estrutura do Repositório (IaC)

A organização modular do diretório `terraform/` garante a manutenção e clareza do projeto:

| Arquivo / Diretório | Função Principal |
| :--- | :--- |
| `main.tf` | **Provedor:** Configuração da conexão e autenticação com a OCI. |
| `network.tf` | **Rede:** Definição da VCN, Subnets, Gateways e Firewalls. |
| `compute.tf` | **Processamento:** Provisionamento da Instância ARM (A1.Flex). |
| `iam.tf` | **Identidade:** Gestão de Dynamic Groups, Usuários e Políticas. |
| `storage.tf` | **Persistência:** Provisionamento do Bucket (Object Storage). |
| `outputs.tf` | **Saídas:** Exibição de IPs e geração de chaves para a Squad. |
| `variables.tf` | **Parametrização:** Declaração das variáveis globais do projeto. |
| `terraform.tfvars` | **Valores Privados:** OCIDs e segredos reais (Não versionado). |
| `acessos_squad3/` | **Secrets:** Diretório gerado contendo as chaves `.pem` e credenciais S3. |
| `scripts/cloud-init.sh` | **Bootstrap:** Instalação automática do Docker/Airflow na VM. |
| `scripts/verify-setup.sh`| **Validação:** Health check pós-deploy da infraestrutura. |
| `scripts/teardown.sh` | **Limpeza:** Procedimentos de destruição e reset do ambiente. |


## 📈 Otimização de Performance
O ambiente foi configurado para reduzir o tempo de pipeline através de:
- **Tuning de Memória:** Alocação de 16GB de RAM dedicada ao DuckDB para operações in-memory.
- **Tuning de CPU:** Configuração de 6 Threads paralelas para compressão Parquet e transformações.
- **S3 Compat:** Integração de alta velocidade entre a VM e o Bucket via API S3 Nativa da Oracle Cloud.