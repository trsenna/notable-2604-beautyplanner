#!/bin/bash

# Sair imediatamente se um comando falhar
set -e

echo "🚀 Iniciando Minikube com 3 nós (Profile: beautyplanner)..."
minikube start --nodes 3 --profile beautyplanner

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
echo "🌐 Como acessar a interface web:"
echo "1. Execute o comando abaixo em um NOVO terminal:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "2. Abra no navegador: https://localhost:8080"
echo "   (Nota: Aceite o aviso de certificado auto-assinado)"
echo "---------------------------------------------------"
