#!/bin/bash

# Exit this script immediately upon encountering errors
set -euo pipefail

# Create store initial admin credentials for use in CLI commands
J_ADMIN_AUTH=admin:`cat /home/jenkins/.jenkins/secrets/initialAdminPassword`

# Export the JENKINS_URL variable
export JENKINS_URL=http://localhost:8080/

# Create a user account and password
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("user1", "password123")' | java -jar jenkins-cli.jar -auth $J_ADMIN_AUTH groovy =

# Install plug-ins

PLUGINS=(git timestamper workflow-aggregator build-timeout email-ext github-branch-source pipeline-github-lib ssh-slaves ws-cleanup blueocean )

for plugin in ${PLUGINS[@]}
  do
    echo "installing jenkins plugin: $plugin"
    java -jar jenkins-cli.jar -auth $J_ADMIN_AUTH install-plugin $plugin
  done

# Restart jenkins
java -jar jenkins-cli.jar -auth $J_ADMIN_AUTH safe-restart
