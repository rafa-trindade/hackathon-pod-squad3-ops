# 📘 Guia de Acesso – Cientistas de Dados  
_Plataforma em Oracle Cloud Infrastructure (OCI)_

---

## 🎯 Objetivo

Este guia explica como:

1. Ler dados do Object Storage  

---

# 🔐 1️⃣ Primeiro Acesso à OCI

Você receberá do administrador:

- URL da tenancy  
- Nome da tenancy  
- Seu username  

---

### ✅ Passos para login

1. Acesse a URL enviada  
2. Informe:
   - Tenancy name  
   - Username  
   - Password  
3. No primeiro login, redefina sua senha  

---

# 🧠 2️⃣ Acessando o Data Science

No menu principal:

☰ → Analytics & AI → **Data Science**

Ou pesquise por **Data Science** na barra superior.

---

# 📓 3️⃣ Criando ou Acessando Notebook Session

1. Clique em **Notebook Sessions**
2. Clique em **Create Notebook Session**
3. Escolha:
   - Compartment correto
   - Shape padrão do projeto
4. Clique em **Create**

Após criação:

Clique em **Open**

O ambiente já estará autenticado via IAM.

---

# 📦 4️⃣ Lendo Dados do Object Storage

A autenticação é automática porque o Notebook assume sua identidade IAM.

### ✅ Exemplo usando Python SDK:

```python
import oci

config = oci.config.from_file()
object_storage = oci.object_storage.ObjectStorageClient(config)

namespace = object_storage.get_namespace().data

response = object_storage.list_objects(
    namespace_name=namespace,
    bucket_name="nome-do-bucket"
)

for obj in response.data.objects:
    print(obj.name)
```

### ✅ Alternativa via CLI dentro do notebook:

```python
!oci os object list --bucket-name nome-do-bucket
```

### 🔒 Permissões

Seu perfil permite:

✔ Ler buckets
✔ Ler objetos
❌ Não permite escrever
❌ Não permite deletar

Isso garante governança e integridade dos dados.
