# 1. Utiliser une image de base Java légère et sécurisée (JRE 17)
FROM eclipse-temurin:17-jre-alpine

# 2. Définir le dossier de travail à l'intérieur du conteneur
WORKDIR /app

# 3. Copier le fichier JAR généré par Maven (dans target/) vers le conteneur
COPY target/web-app.jar app.jar

# 4. Indiquer le port sur lequel l'application écoute à l'intérieur du conteneur
EXPOSE 8080

# 5. Commande pour exécuter l'application Java
CMD ["java", "-jar", "app.jar"]
