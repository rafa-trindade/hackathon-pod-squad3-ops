#!/bin/bash
# ==============================================================================
# SQUAD 3 - HEALTH CHECK & CLOUD READINESS VERIFICATION (VERSÃO UBUNTU)
# Objetivo: Validar se o Bootstrap foi concluído com sucesso
# ==============================================================================

echo "--- [1/1] Verificando Prontidão da Instância ---"
echo ""

check() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ $2"
    fi
}

# 1. Docker instalado?
docker --version &> /dev/null
check "Docker instalado" "Docker NÃO encontrado."

# 2. Docker Compose instalado?
docker compose version &> /dev/null
check "Docker Compose instalado" "Docker Compose NÃO encontrado."

# 3. Permissões do usuário?
groups ubuntu | grep -q docker
check "Permissões de usuário (ubuntu) para Docker OK" "Permissões do Docker para o usuário 'ubuntu' ausentes. Tente relogar (exit e ssh novamente)."

# 4. Estrutura de pastas?
[ -d "/home/ubuntu/app" ]
check "Estrutura de pastas /home/ubuntu/app OK" "Estrutura de pastas /home/ubuntu/app ausente."

# 5. Conectividade com a Internet?
ping -c 1 google.com &> /dev/null
check "Conectividade com a Internet OK" "Sem acesso à Internet."

# 6. Diretório temporário do DuckDB?
[ -d "/mnt/nvme/duckdb_temp" ]
check "Diretório temporário do DuckDB (/mnt/nvme/duckdb_temp) OK" "Diretório temporário do DuckDB ausente."

echo ""
echo "--- VERIFICAÇÃO CONCLUÍDA ---"
