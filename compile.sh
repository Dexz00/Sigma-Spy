#!/bin/bash
# Script de Compilação - Sigma Spy
# Bash Script para Linux/Mac

echo "🔧 Iniciando compilação do Sigma Spy..."
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar se Lune está instalado
if ! command -v lune &> /dev/null; then
    echo -e "${RED}❌ ERRO: Lune não está instalado!${NC}"
    echo -e "${YELLOW}📥 Instale em: https://github.com/lune-org/lune${NC}"
    echo -e "${YELLOW}   Execute: cargo install lune${NC}"
    exit 1
fi

# Verificar se DarkLua está instalado
if ! command -v darklua &> /dev/null; then
    echo -e "${RED}❌ ERRO: DarkLua não está instalado!${NC}"
    echo -e "${YELLOW}📥 Instale em: https://github.com/seaofvoices/darklua${NC}"
    echo -e "${YELLOW}   Execute: cargo install darklua${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependências verificadas${NC}"
echo ""

# Fazer backup do arquivo anterior se existir
if [ -f "Main.lua" ]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="Main_backup_$timestamp.lua"
    cp "Main.lua" "$backup_file"
    echo -e "${YELLOW}💾 Backup criado: $backup_file${NC}"
fi

# Executar compilação
echo -e "${CYAN}🔨 Compilando...${NC}"
lune run build/build.lua build/config.json

# Verificar se compilação foi bem-sucedida
if [ $? -eq 0 ] && [ -f "Main.lua" ]; then
    echo ""
    echo -e "${GREEN}✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
    echo ""
    
    file_size=$(stat -f%z "Main.lua" 2>/dev/null || stat -c%s "Main.lua" 2>/dev/null)
    file_size_kb=$(echo "scale=2; $file_size / 1024" | bc)
    
    echo -e "${CYAN}📄 Arquivo gerado: Main.lua${NC}"
    echo -e "${CYAN}📊 Tamanho: $file_size_kb KB${NC}"
    echo ""
    echo -e "${YELLOW}🚀 Próximos passos:${NC}"
    echo "   1. Teste o arquivo Main.lua"
    echo "   2. Faça upload para seu repositório GitHub"
    echo "   3. Use a URL raw no seu executor"
else
    echo ""
    echo -e "${RED}❌ ERRO NA COMPILAÇÃO!${NC}"
    echo -e "${YELLOW}Verifique as mensagens de erro acima${NC}"
    exit 1
fi

