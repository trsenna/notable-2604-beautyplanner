#!/bin/bash

# Extrair a chave pública da Root CA do cluster
echo "📥 Extraindo Root CA do cert-manager..."
kubectl get secret beautyplanner-ca-secret -n cert-manager -o jsonpath='{.data.ca\.crt}' | base64 -d > rootCA.crt

echo "✅ Arquivo 'rootCA.crt' gerado com sucesso!"
echo "---------------------------------------------------"
echo "🔐 Próximos passos no seu HOST (Notebook):"
echo "1. Baixe o arquivo 'rootCA.crt' para sua máquina."
echo "2. Instale-o nas Autoridades de Certificação Confiáveis do seu sistema operacional."
echo "3. Reinicie seu navegador."
echo "4. Acesse as aplicações via https://planner.localhost:8443 e https://argocd.localhost:8443"
echo "---------------------------------------------------"
