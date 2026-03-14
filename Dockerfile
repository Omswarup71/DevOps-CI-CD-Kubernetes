FROM openjdk:8-jdk-slim

# Create a directory for the app
WORKDIR /app

EXPOSE 8080

# Copy from the target folder to our workdir
COPY target/devops-integration.jar app.jar

# Run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
