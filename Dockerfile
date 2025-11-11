# ======================================================
# 🏗 Stage 1 — build with Maven on JDK 25
# ======================================================
FROM amazoncorretto:25 AS builder

USER root
WORKDIR /app

# Install Maven + git
RUN yum install -y maven git && yum clean all

# Copy project files
COPY pom.xml .
COPY src ./src

# 👇 Disable Error-Prone and open restricted module
RUN mvn clean package -DskipTests -Derrorprone=false \
    -DcompilerArgs="--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED"

# ======================================================
# 🚀 Stage 2 — lightweight runtime on JDK 25
# ======================================================
FROM amazoncorretto:25

# OpenShift-compatible non-root UID
USER 185
WORKDIR /app

# Copy JAR from builder
COPY --from=builder /app/target/*.jar /app/app.jar

EXPOSE 8080
HEALTHCHECK CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
