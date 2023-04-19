#!/bin/bash

#install bcrypt
sudo apt-get install bcrypt

# Define variables
CONTAINER_NAME="jenkins"
JENKINS_ADMIN_USER="Kavi"
JENKINS_ADMIN_PASSWORD="Kavi"

# Pull the latest Jenkins image
docker pull jenkins/jenkins:lts

# Create a Jenkins container with a persistent volume
docker run -d --name $CONTAINER_NAME \
    -p 8080:8080 -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    jenkins/jenkins:lts

# Wait for Jenkins to start
while ! curl -s http://localhost:8080/login >/dev/null; do sleep 1; done

# Get initial admin password
ADMIN_PASSWORD=$(sudo docker exec $CONTAINER_NAME cat /var/jenkins_home/secrets/initialAdminPassword)

# Install suggested plugins
sudo docker exec $CONTAINER_NAME java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin git workflow-aggregator

sudo docker exec $CONTAINER_NAME 'java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ groovy =
"
import jenkins.model.*
import hudson.security.*
import hudson.util.*
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('${JENKINS_ADMIN_USER}', '${JENKINS_ADMIN_PASSWORD}')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
"'

# Restart Jenkins container
docker restart $CONTAINER_NAME
