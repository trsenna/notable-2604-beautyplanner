#!/bin/bash

# Sair imediatamente se um comando falhar
set -e

echo "🚀 Iniciando Minikube com 3 nós (Profile: beautyplanner)..."
minikube start --nodes 3 --profile beautyplanner

echo "⚙️ Habilitando addons..."
minikube addons enable ingress --profile beautyplanner

echo "⚙️ Instalando cert-manager via manifesto oficial..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

echo "⏳ Aguardando os Pods do Ingress e cert-manager estarem prontos..."
kubectl wait --for=condition=Ready pods --all -n ingress-nginx --timeout=300s
kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=300s

echo "📂 Aplicando configurações de PKI (cert-manager)..."
kubectl apply -f platform/k8s/cert-manager/

echo "⚙️ Configurando certificado TLS padrão no Ingress..."
# Aguarda os secrets serem gerados pelo cert-manager
kubectl wait --for=condition=Ready certificate/localhost-wildcard-cert -n cert-manager --timeout=60s

# Patch no deployment do ingress-nginx para usar o certificado padrão (fallback)
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--default-ssl-certificate=cert-manager/localhost-tls-secret"}]'

echo "📂 Criando namespace 'argocd'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "⚙️ Instalando ArgoCD..."
kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Aguardando os Pods do ArgoCD estarem prontos (isso pode levar alguns minutos)..."
# O wait pode falhar se os pods ainda não foram criados, então damos um pequeno sleep
sleep 10
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo ""
echo "✅ ArgoCD instalado com sucesso!"
echo "---------------------------------------------------"
echo "🔐 Credenciais de Acesso:"
echo "Usuário: admin"
echo -n "Senha: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "---------------------------------------------------"
echo "🌐 Como acessar as aplicações:"
echo "1. Execute o port-forward do Ingress em um NOVO terminal:"
echo "   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443"
echo ""
echo "2. Extraia e instale a CA no seu navegador rodando:"
echo "   ./platform/scripts/extract-ca.sh"
echo ""
echo "3. Abra no navegador:"
echo "   - ArgoCD: https://argocd.localhost:8443"
echo "   - Planner Command: https://planner.localhost:8443/command"
echo "   - Planner Query: https://planner.localhost:8443/query"
echo "---------------------------------------------------"
