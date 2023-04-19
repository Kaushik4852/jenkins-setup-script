#!/bin/bash

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

# Set Jenkins admin username and password
curl -X POST -H "Content-Type:application/xml" -d "<jenkins><securityRealm class=\"hudson.security.HudsonPrivateSecurityRealm\"><disableSignup>true</disableSignup><users><hudson.model.User><id>${JENKINS_ADMIN_USER}</id><passwordHash>#jbcrypt:\$(bcrypt \$(echo -n ${JENKINS_ADMIN_PASSWORD}))#</passwordHash></hudson.model.User></users></securityRealm><authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\"><denyAnonymousReadAccess>true</denyAnonymousReadAccess></authorizationStrategy></jenkins>" -u admin:$ADMIN_PASSWORD http://localhost:8080/config.xml

# Restart Jenkins container
docker restart $CONTAINER_NAME
