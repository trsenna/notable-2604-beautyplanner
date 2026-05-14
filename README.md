# Beauty Planner

Sistema de gestão de salão/clínica utilizando arquitetura de microsserviços Cloud Native e CQRS.

> **Nota para Desenvolvedores e IA:**
> Toda a documentação técnica, regras de arquitetura, padrões de infraestrutura (Kubernetes, ArgoCD, GitHub Actions) e diretrizes de contribuição estão consolidadas no arquivo `AGENTS.md`. Consulte-o antes de realizar qualquer alteração estrutural no projeto.

## Setup Local Rápido (k3d)

Pré-requisitos: [Docker](https://docs.docker.com/get-docker/), [kubectl](https://kubernetes.io/docs/tasks/tools/), [k3d](https://k3d.io/stable/#installation) (v5+).

1. `./platform/scripts/k3d-setup.sh` — cria cluster **k3d** (1 server, 2 agents), NGINX Ingress, cert-manager, PKI do repositório e Argo CD.
2. `./platform/scripts/extract-ca.sh` — gera `rootCA.crt`; importe como CA confiável no SO/navegador.
3. `kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443`

Para remover o cluster: `./platform/scripts/k3d-cleanup.sh`. Nome do cluster padrão: `beautyplanner` (sobrescreva com `K3D_CLUSTER_NAME` se necessário).
