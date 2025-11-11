# ==============================================================
# 🏗️ Stage 1 — Build the Spring PetClinic app with Maven + JDK 25
# ==============================================================
FROM amazoncorretto:25 AS builder

USER root
WORKDIR /app

# Install Maven
RUN yum install -y maven git && yum clean all

# Copy only the pom.xml first (for dependency caching)
COPY pom.xml .

# Pre-fetch dependencies
RUN mvn dependency:go-offline -B

# Copy the full source code
COPY src ./src

# Build the application (skip tests)
RUN mvn clean package -DskipTests

# ==============================================================
# 🚀 Stage 2 — Runtime image (JDK 25 only)
# ==============================================================
FROM amazoncorretto:25

# Use OpenShift-friendly non-root UID
USER 185
WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder /app/target/*.jar /app/app.jar

# Expose default Spring Boot port
EXPOSE 8080

# Optional health check
HEALTHCHECK CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the app
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
