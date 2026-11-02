#!/usr/bin/env bash
# Executar dentro da VM Ubuntu 24.04.
set -euo pipefail
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk maven git curl ca-certificates gnupg lsb-release
# Instalador oficial Microsoft Azure CLI.
curl -fsSL https://aka.ms/InstallAzureCLIDeb -o /tmp/zelo-install-azure-cli.sh
sudo bash /tmp/zelo-install-azure-cli.sh
java -version
mvn -version
git --version
az version
