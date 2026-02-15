#!/bin/bash
# ==============================================================================
# SQUAD 3 - VERIFICAÇÃO DE PRONTIDÃO DA INSTÂNCIA (OPS ENGINE)
# Objetivo: Realizar uma verificação abrangente da configuração da instância 
# ==============================================================================

# Redirecionar toda a saída do script para um arquivo de log e também para o console, facilitando a depuração e monitoramento do processo de verificação
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

# 3. Permissões do usuário 'ubuntu' para Docker?
groups ubuntu | grep -q docker
check "Permissões de usuário (ubuntu) para Docker OK" "Permissões do Docker para o usuário 'ubuntu' ausentes. Tente relogar (exit e ssh novamente)."

# 4. Estrutura de pastas criada?
[ -d "/home/ubuntu/app" ]
check "Estrutura de pastas /home/ubuntu/app OK" "Estrutura de pastas /home/ubuntu/app ausente."

# 5. Conectividade com a Internet?
ping -c 1 google.com &> /dev/null
check "Conectividade com a Internet OK" "Sem acesso à Internet."

# 6. Diretório temporário do DuckDB criado?
[ -d "/mnt/nvme/duckdb_temp" ]
check "Diretório temporário do DuckDB (/mnt/nvme/duckdb_temp) OK" "Diretório temporário do DuckDB ausente."

echo ""
echo "--- VERIFICAÇÃO CONCLUÍDA ---"
