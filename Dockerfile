FROM openjdk:8u131-jdk-alpine

MAINTAINER Richard Chesterwood "contact@virtualpairprogrammers.com"

EXPOSE 8080

WORKDIR /usr/local/bin/

COPY fleetman.jar webapp.jar

CMD ["java", "-Xmx50m","-jar","webapp.jar"]
