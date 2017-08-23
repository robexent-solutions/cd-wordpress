#!/bin/bash

# Exit this script immediately upon encountering errors
set -euo pipefail

# Install wget
yum -y install wget

# Install git
yum -y install git

# Install packer
yum -y install zip unzip
wget -nv https://releases.hashicorp.com/packer/1.0.4/packer_1.0.4_linux_amd64.zip
unzip packer_1.0.4_linux_amd64.zip
mv packer /usr/local/bin/.

# Install java
wget -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jre-8u144-linux-x64.rpm
yum -y localinstall jre-8u144-linux-x64.rpm 

# Install jenkins
useradd -m jenkins
cd /home/jenkins
su - jenkins -c 'wget -nv https://updates.jenkins-ci.org/download/war/2.74/jenkins.war'
su - jenkins -c 'cp /vagrant/start_jenkins.sh .'
su - jenkins -c /home/jenkins/start_jenkins.sh


# Obtain jenkins CLI
sleep 60 # Wait for Jenkins to start
su - jenkins -c 'wget -nv http://localhost:8080/jnlpJars/jenkins-cli.jar'

# Update jenkins bash profile to include environment variables and helper functions
su - jenkins -c 'echo "export JENKINS_URL=http://localhost:8080/" >> .bash_profile'
#su - jenkins -c 'echo "function jenkins-cli () { java -jar ~/jenkins-cli.jar $@ }" >> .bash_profile'
su - jenkins -c 'cat << EOF >> .bash_profile
function jenkins-cli () {
  java -jar ~/jenkins-cli.jar \$@
}
EOF
'
