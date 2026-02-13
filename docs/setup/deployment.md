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
# Navegue até o diretório do Terraform
cd ~/app/hackathon-pod-squad3-ops/terraform

# Inicialize, planeje e aplique a configuração
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve

# Copie o IP que aparecerá no output: instancia_ip_publico.
# Exemplo: 144.22.146.237
```

---

### 🌐 Passo 1: Acesso e Verificação do Bootstrap (VM)

```bash
ssh -i ~/.ssh/oci_windows_key ubuntu@{IP_PUBLICO}

tail -f /var/log/user-data.log

# Aperte CTRL+C apenas quando aparecer "BOOTSTRAP FINALIZADO COM SUCESSO"
```

---

### Passo 2: Configurar Acesso ao GitHub (Deploy Keys)

```bash
# Gere uma nova chave SSH DENTRO da VM
ssh-keygen -t ed25519 -C "oracle-vm-squad3"

# Pressione Enter três vezes para aceitar o local padrão e não usar senha.

# Exiba a nova chave pública
cat ~/.ssh/id_ed25519.pub

# Copie a chave pública (a linha inteira que começa com ssh-ed25519)
# e adicione como uma "Deploy Key" com permissão de leitura nos seus repositórios do GitHub:
# 1. `hackathon-pod-squad3-ops`
# 2. `hackathon-pod-squad3-core`
```

---

### 🚀 Passo 3: Clonar Repositórios e Validar Ambiente

```bash
# Navegue até o diretório de aplicativos do usuário 'ubuntu'
cd /home/ubuntu/app

# Clone os repositórios usando as Deploy Keys que você acabou de configurar
git clone git@github.com:rafa-trindade/hackathon-pod-squad3-ops.git
git clone git@github.com:rafa-trindade/hackathon-pod-squad3-core.git

# Verifique se o script de verificação está correto (se ele existir)
cd /home/ubuntu/app/hackathon-pod-squad3-ops/terraform/scripts
chmod +x verify-setup.sh
./verify-setup.sh
```

---

### ⚙️ Passo 4: Iniciar Orquestrador (Airflow)

```bash
# Navegue até a pasta do orquestrador
cd /home/ubuntu/app/hackathon-pod-squad3-ops/orchestrator

# Crie o arquivo de configuração de ambiente a partir do exemplo
cp .env.example .env

# (Opcional) Edite o arquivo .env se precisar ajustar alguma variável
# nano .env

# Dê as permissões necessárias para o Airflow escrever nos diretórios
sudo chmod -R 777 ./logs ./plugins ./dags

# Inicialize o banco de dados e o usuário do Airflow
docker compose up airflow-init

# Inicie todos os outros serviços do Airflow em background
docker compose up -d
```


