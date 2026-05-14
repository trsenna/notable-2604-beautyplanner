# Beauty Planner - AI Assistant Guidelines & Architecture

This document contains foundational mandates and architectural constraints for AI assistants working on this project. These instructions take absolute precedence.

## 1. Interaction & Workflow Mandates
- **Commit Messages:** ALWAYS write commit messages in the imperative mood (e.g., "Add feature X", "Update dependency Y"). DO NOT use Conventional Commits (e.g., no `feat:`, `fix:`). DO NOT use specific GitFlow naming conventions.
- **Audience:** Do not generate human-centric documentation or tutorials unless explicitly requested. Optimize all explanations and comments for AI consumption.

## 2. Domain Context & Ubiquitous Language
The project is a management system for Beauty Clinics/Salons. All development must respect these core entities:
- **Customer:** The person receiving the service. Contains profile, contact, and history.
- **Procedure:** The specific service provided (e.g., Haircut, Botox, Massage). Has duration and price.
- **Appointment:** The core event. Links a Customer to one or more Procedures at a specific Time/Date.
- **Status Flow:** Appointments follow a strict flow: `SCHEDULED` -> `CONFIRMED` -> `COMPLETED` or `CANCELLED`.

## 3. Architecture (CQRS)
The system is a Cloud Native microservices architecture using the Command Query Responsibility Segregation (CQRS) pattern.

- **`services/planner-command`**: Write Model (API). Handles business rules, validations, and state mutations. Future DB: PostgreSQL.
- **`services/planner-query`**: Read Model (API). Returns optimized data for the UI. Future DB: MongoDB.
- **`services/planner-sync`**: Background worker consuming events from Command to update Query read models. Future Messaging: RabbitMQ.
- **Namespace/Packages:** Must always use `io.planner`.
- **Stack:** Java 25, Spring Boot 3.x.

## 4. Project Structure Constraints
- **Multi-Module Strictness:** The project is strictly divided.
  - `/services`: Contains executable microservices. Each service is 100% independent. NEVER create shared libraries or folders (like `/libs`) outside of a service's root that it depends on for building.
  - `/platform`: Contains infrastructure code, Kubernetes manifests (Kustomize), CI/CD workflows, and scripts.

## 5. Platform Engineering & DevOps (DevOps-first)
- **Deployment Strategy:** GitOps driven (GitHub Actions -> ArgoCD -> Kubernetes). Kustomize is used for manifest management per service.
- **Network & Security (Ingress & HTTPS):**
  - **Single Entrypoint:** NGINX Ingress Controller is used as the single point of entry. All services are exposed via specific paths (e.g., `/command`, `/query`) rather than separate domains.
  - **TLS/HTTPS:** The cluster enforces HTTPS using `cert-manager`. A local PKI setup (Custom CA) is used to generate wildcard certificates (e.g., `*.localhost`).
  - **Rule:** Any new service exposed to the outside MUST have an Ingress manifest configured with TLS via the `cert-manager` cluster-issuer.
- **Dockerfile Constraints:** Every service in `/services` MUST have its own `Dockerfile` and `.dockerignore` following these strict rules:
  1. **Isolated Build Context:** The Docker build context is always the root of the specific service.
  2. **Multi-stage Build:** Clearly separate the build stage (JDK) from the runtime stage (lean JRE Alpine) to prevent source code and build tools leakage.
  3. **Layer Caching:** Maven files (`.mvn`, `mvnw`, `pom.xml`) MUST be copied and dependencies downloaded offline *before* copying the source code (`src/`).
  4. **Security (Non-root):** Containers MUST NEVER run as `root`. The final production image must use generic numeric IDs (UID `1001`, GID `1001`) to comply with restrictive Kubernetes SecurityContext policies.

## 6. Observability (LGTM Stack)
The project uses the LGTM stack (Loki, Grafana, Tempo, Mimir/Prometheus) for comprehensive observability, managed via ArgoCD in the `monitoring` namespace.
- **Tools:**
  - **Prometheus & Grafana:** Managed via `kube-prometheus-stack`. Grafana is the central visualization tool.
  - **Loki:** Log aggregation system.
  - **Tempo:** Distributed tracing backend.
- **Endpoints:**
  - Grafana: `https://grafana.localhost`
  - Prometheus: `https://prometheus.localhost`
- **Current State:** The stack is provisioned at the infrastructure level. Application-level integration (Micrometer, OpenTelemetry, etc.) is a pending task for the Java services.

## 7. Cursor Cloud specific instructions
- **Cluster local:** Bootstrap via k3d multi-node (`platform/scripts/k3d-setup.sh`, cleanup em `k3d-cleanup.sh`). Traefik desativado no K3s; ingress único continua sendo NGINX, alinhado à seção 5.
- Os 3 serviços usam a porta 8080 por padrão. Execute um por vez ou sobrescreva `server.port`.
- O endpoint de tracing (`tempo.monitoring.svc.cluster.local`) não é acessível fora do cluster — o warning no startup é esperado e não impede a execução.
- Só abra uma PR quando a tarefa estiver concluída e confirmada, ou quando for explicitamente solicitado.
