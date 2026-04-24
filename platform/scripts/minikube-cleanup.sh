#!/bin/bash

# Sair imediatamente se um comando falhar
set -e

echo "🔥 Destruindo o cluster Minikube (Profile: beautyplanner)..."
echo "Isso removerá os nós, o ArgoCD e todas as aplicações instaladas."

minikube delete --profile beautyplanner

echo "✨ Tudo limpo! O profile 'beautyplanner' foi removido com sucesso."
