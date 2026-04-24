# ==========================================
# Build Stage
# ==========================================
FROM eclipse-temurin:25-jdk-alpine AS builder

WORKDIR /build

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B

COPY src src
RUN ./mvnw clean package -DskipTests
RUN mv target/*.jar target/app.jar

# ==========================================
# Runtime Stage
# ==========================================
FROM eclipse-temurin:25-jre-alpine

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app
RUN chown -R appuser:appgroup /app

USER 1001

COPY --from=builder /build/target/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
