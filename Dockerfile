# ==============================================================
# 🏗️ Stage 1 — Build the application using Maven and JDK 25
# ==============================================================
FROM amazoncorretto:25 AS builder

# Set work directory inside container
WORKDIR /app

# Copy Maven project descriptor
COPY pom.xml .

# Copy source code
COPY src ./src

# Build the application (skip tests to speed up)
RUN ./mvnw clean package -DskipTests || mvn clean package -DskipTests

# ==============================================================
# 🚀 Stage 2 — Create a lightweight runtime image
# ==============================================================
FROM amazoncorretto:25

# Create application directory
WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder /app/target/*.jar /app/app.jar

# Expose application port (default Spring Boot port)
EXPOSE 8080

# Health check (optional)
HEALTHCHECK CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
