#!/bin/bash

# Exit if any commands fail
set -euo pipefail

# Install web utilities
yum -y install wget curl

# Install zip/unzip
yum -y install zip unzip

# Install git
yum -y install git

