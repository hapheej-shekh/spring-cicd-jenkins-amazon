# Base image: lightweight OpenJDK 11
FROM openjdk:11-jdk-slim

# Optional: Set timezone for logging consistency
ENV TZ=Asia/Kolkata

# Set Spring profile (overridable via -e flag)
ENV SPRING_PROFILES_ACTIVE=dev

# Set working directory
WORKDIR /spring-cicd-jenkins-amazon

# Used ADD instead of COPY [May later support zipped builds]
ADD target/*.jar amazon-jenkins-app.jar

# Expose project port(default: 8080)
EXPOSE 8085

# Run the application/jar
ENTRYPOINT ["java", "-jar", "amazon-jenkins-app.jar"]
