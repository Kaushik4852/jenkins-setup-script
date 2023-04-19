#!/bin/bash

# Define variables
JENKINS_ADMIN_USER="admin"
JENKINS_ADMIN_PASSWORD="your-admin-password"
JENKINS_PORT=8080

# Pull the latest Jenkins image
sudo docker pull jenkins/jenkins:lts

# Start the Jenkins container
sudo docker run -d -p $JENKINS_PORT:$JENKINS_PORT --name jenkins \
-e JENKINS_ADMIN_ID=$JENKINS_ADMIN_USER -e JENKINS_ADMIN_PASSWORD=$JENKINS_ADMIN_PASSWORD \
-e JENKINS_OPTS="--argumentsRealm.passwd.$JENKINS_ADMIN_USER=$JENKINS_ADMIN_PASSWORD --argumentsRealm.roles.$JENKINS_ADMIN_USER=admin" \
jenkins/jenkins:lts

# Wait for Jenkins to start
while ! curl -s http://localhost:$JENKINS_PORT/login >/dev/null; do sleep 1; done

# Retrieve the Jenkins admin API token
JENKINS_API_TOKEN=$(sudo docker exec jenkins sh -c "echo \$(cat /var/jenkins_home/secrets/initialAdminPassword)")

# Output Jenkins admin API token to console
echo "Jenkins admin API token: $JENKINS_API_TOKEN"
