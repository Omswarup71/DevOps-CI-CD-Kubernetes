FROM eclipse-temurin:8-jdk
WORKDIR /app
COPY target/devops-integration.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
