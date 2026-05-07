# Beauty Planner - Agent Guidelines

## Cursor Cloud specific instructions

### Overview

Java 25 Spring Boot monorepo with 3 independent microservices under `/services/`:
- `planner-command` — Write model API (port 8080 by default)
- `planner-query` — Read model API (port 8080 by default)
- `planner-sync` — Event consumer worker (port 8080 by default)

Each service is fully independent with its own Maven Wrapper. There is no parent POM.

### Java version

The project requires **Java 25**. Installed via SDKMAN (`25.0.3-tem`). SDKMAN is sourced in `~/.bashrc`, so shells get it automatically. If you need to ensure it's active, run:
```
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Build / Test / Run

Each service is operated independently from its own directory:

```bash
cd services/planner-command   # or planner-query, planner-sync

./mvnw compile                # compile
./mvnw test                   # run tests
./mvnw spring-boot:run        # run in dev mode (port 8080)
```

Since all 3 services default to port 8080, only run one at a time unless you override `server.port`.

### Key endpoints (when a service is running)

- Health: `GET /actuator/health`
- Liveness: `GET /actuator/health/liveness`
- Readiness: `GET /actuator/health/readiness`
- Prometheus metrics: `GET /actuator/prometheus`

### Gotchas

- The tracing endpoint in `application.properties` points to an in-cluster Tempo service (`http://tempo.monitoring.svc.cluster.local:4318/v1/traces`). This causes a non-blocking warning at startup when running locally — it does **not** prevent the service from starting.
- No database or messaging dependencies are wired yet; the services are scaffold-level and run fine standalone.
- Commit messages must be imperative mood, no Conventional Commits prefixes (see `GEMINI.md`).
- All packages must use the `io.planner` namespace.
