# 🔐 Guia do Administrador – Provisionamento de Acesso  
_Plataforma em Oracle Cloud Infrastructure (OCI)_

---

## 🎯 Objetivo

Este guia descreve o passo a passo para:

1. Validar criação do usuário via Terraform
2. Criar senha temporária
3. Validar permissões
4. Enviar credenciais ao analistas/cientistas

---

# 🧩 1️⃣ Validar Usuário Criado

Caso o usuário tenha sido criado via Terraform:

Menu → Identity & Security → **Users**

Verifique:

✔ Usuário existe  
✔ Email correto (se aplicável)  
✔ Status ativo  

---

# 👥 2️⃣ Verificar Grupo do Usuário

Menu → Identity & Security → **Users**  
Selecionar usuário → **Groups**

Confirme que o usuário está no grupo correto, por exemplo:

- `analytics_group`

Caso não esteja:

1. Clique em **Add User to Group**
2. Selecione o grupo correto
3. Salve

---

# 📜 3️⃣ Validar Políticas de Acesso

Menu → Identity & Security → **Policies**

Confirme que o grupo possui políticas como:

```text
Allow group squad3-analytics-group to read objects in compartment <compartment_name>
Allow group squad3-analytics-group to inspect buckets in compartment <compartment_name>
```

Sem essas políticas o usuário não conseguirá:

- Ler Object Storage

---

# 🔐 4️⃣ Criar Senha Temporária

⚠️ Usuários criados via Terraform NÃO possuem senha automaticamente.

Passo a passo:

1. Menu → Identity & Security → **Users**
2. Selecione o usuário
3. Clique em **Reset Password**
4. Defina uma senha temporária
5. Marque obrigatoriedade de redefinição no primeiro login
6. Salve

---

# 🌐 5️⃣ Coletar Informações para Envio

## 🔎 URL da Tenancy

Canto superior direito → Profile → **Tenancy Details**

Formato padrão:

https://cloud.oracle.com/?tenant=<nome_da_tenancy>

---

## 🏷 Nome da Tenancy

Canto superior direito → Profile → **Tenancy Name**

---

## 👤 Username

Identity & Security → Users → Campo **Name**

---

# 📤 6️⃣ Enviar Credenciais ao Cientista

Enviar:

- URL da tenancy
- Nome da tenancy
- Username
- Senha temporária

---

# ✅ 7️⃣ Checklist Final

Antes de considerar o acesso concluído:

✔ Usuário criado  
✔ Grupo correto atribuído  
✔ Políticas aplicadas  
✔ Senha temporária criada  
✔ Compartimento validado  
✔ Serviço Data Science disponível no compartment  

