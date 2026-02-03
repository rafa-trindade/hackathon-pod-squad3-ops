#!/bin/bash
# ==============================================================================
# SQUAD 3 - HEALTH CHECK & CLOUD READINESS VERIFICATION
# Objetivo: Validar se o Bootstrap foi concluído com sucesso
# ==============================================================================

echo "--- [1/1] Verificando Prontidão da Instância ---"

docker --version && echo "✅ Docker instalado" || echo "❌ Docker ausente"

docker compose version && echo "✅ Docker Compose instalado" || echo "❌ Docker Compose ausente"

groups opc | grep -q docker && echo "✅ Permissões de usuário (opc) OK" || echo "⚠️ Usuário precisa relogar para assumir grupo docker"

[ -d "/home/opc/app" ] && echo "✅ Estrutura de pastas /app OK" || echo "❌ Estrutura de pastas ausente"

ping -c 1 google.com &> /dev/null && echo "✅ Conectividade com Internet OK" || echo "❌ Sem acesso à Internet"

[ -d "/tmp/duckdb_storage" ] && echo "✅ Cache DuckDB (/tmp/duckdb_storage) OK" || echo "❌ Cache DuckDB ausente"

echo "--- BOOTSTRAP VERIFICADO COM SUCESSO ---"