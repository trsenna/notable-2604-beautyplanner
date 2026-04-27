# Beauty Planner

Sistema de gestão de salão/clínica utilizando arquitetura de microsserviços Cloud Native e CQRS.

> **Nota para Desenvolvedores e IA:**
> Toda a documentação técnica, regras de arquitetura, padrões de infraestrutura (Kubernetes, ArgoCD, GitHub Actions) e diretrizes de contribuição estão consolidadas no arquivo `GEMINI.md`. Consulte-o antes de realizar qualquer alteração estrutural no projeto.

## Setup Local Rápido
1. `./platform/scripts/minikube-setup.sh`
2. `./platform/scripts/extract-ca.sh` (Importe o `rootCA.crt` no seu SO/Browser)
3. `kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443`
