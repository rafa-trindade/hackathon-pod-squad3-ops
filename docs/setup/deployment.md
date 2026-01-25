## Guia de Deploy - Squad 3 (OCI)

Este guia contém os comandos necessários para provisionar a infraestrutura e inicializar o ambiente de orquestração.

**Pré-requisito: Gerar chave de acesso (caso não tenha)**
```bash
# verificação 
ls ~/.ssh/

# (Opcional) Se não tiver nenhuma, gere uma nova:
# ssh-keygen -t ed25519 -C "sua_chave"

cat ~/.ssh/id_ed25519.pub
# Copie o conteúdo acima e coloque na variável ssh_public_key no terraform.tfvars
```

---

### 🏗️ 0. Provisionamento da Infraestrutura (Local)

```bash
cd terraform
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve

# Copie o IP que aparecerá no output: instancia_ip_publico.
```

---

### 🌐 Passo 1: Acesso e Verificação do Bootstrap (VM)

```bash
ssh -i ~/.ssh/id_ed25519 opc@{IP_PUBLICO}
tail -f /var/log/user-data.log

# Apertar CTRL+C apenas quando aparecer "BOOTSTRAP FINALIZADO COM SUCESSO"
```

---

### Passo 2: Configurar Acesso ao GitHub (Deploy Keys)

```bash
ssh-keygen -t ed25519 -C "oracle-vm-squad3"
cat ~/.ssh/id_ed25519.pub

# Deploy Key nos repositórios:
# 1. `hackathon-pod-squad3-ops`
# 2. `hackathon-pod-squad3-core`
```

---

### 🚀 Passo 3: Clonar Repositórios e Validar Ambiente

```bash
cd /home/opc/app
git clone git@github.com:rafa-trindade/hackathon-pod-squad3-ops.git
git clone git@github.com:rafa-trindade/hackathon-pod-squad3-core.git

cd /home/opc/app/hackathon-pod-squad3-ops/terraform/scripts
chmod +x verify-setup.sh
./verify-setup.sh
```

---

### ⚙️ Passo 4: Iniciar Orquestrador (Airflow)

```bash
cd /home/opc/app/hackathon-pod-squad3-ops/orchestrator

cp .env.example.vm .env 

mkdir -p ./logs ./plugins ./dags
sudo chmod -R 777 ./logs ./plugins ./dags

docker compose up airflow-init

docker compose up -d
```


