# Beauty Planner (Cloud Native & CQRS)

Sistema de gestão de salão/clínica utilizando arquitetura de microsserviços.

## 🚀 Como Iniciar (Ambiente Local)

### 1. Pré-requisitos
- Minikube instalado.
- Kubectl instalado.

### 2. Setup do Cluster
Execute o script de inicialização para subir o cluster com 3 nós, ArgoCD, Ingress e cert-manager:

```bash
./platform/scripts/minikube-setup.sh
```

### 3. Configuração do HTTPS (Cadeado Verde)
Para acessar as aplicações sem alertas de segurança, você precisa confiar na Autoridade Certificadora (CA) do cluster:

1. Gere o arquivo do certificado:
   ```bash
   ./platform/scripts/extract-ca.sh
   ```
2. Baixe o arquivo `rootCA.crt` gerado para o seu computador.
3. Importe este certificado no seu Sistema Operacional ou Navegador como uma "Autoridade de Certificação Raiz Confiável".
4. Reinicie o navegador.

### 4. Acesso às Aplicações
Em um terminal separado, mantenha o port-forward do Ingress rodando:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443
```

Acesse via:
- **ArgoCD:** [https://argocd.localhost:8443](https://argocd.localhost:8443)
- **Planner APIs:** [https://planner.localhost:8443/command](https://planner.localhost:8443/command) (ou `/query`, `/sync`)

## 🏗️ Arquitetura
Consulte o arquivo [docs/architecture.md](docs/architecture.md) para detalhes técnicos.
