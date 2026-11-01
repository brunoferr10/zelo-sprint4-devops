#!/usr/bin/env bash
set -euo pipefail

# Configuracoes nao sensiveis. Os nomes seguem o RM do representante.
export RM="563489"
export LOCATION="canadacentral"
export RESOURCE_GROUP="rg-zelo-s4-rm${RM}"
export ACR_NAME="zelos4acr${RM}"
export STORAGE_ACCOUNT="zelos4data${RM}"
export FILE_SHARE="zelo-mysql-data"
export KEY_VAULT="kv-zelos4-${RM}"
export DB_ACI="rm${RM}-zelos4-db"
export APP_ACI="rm${RM}-zelos4-app"
export DB_IMAGE="${RM}-zelo-db"
export APP_IMAGE="${RM}-zelo-app"
export IMAGE_TAG="${IMAGE_TAG:-v1}"

require_secret() {
  local variable
  for variable in "$@"; do
    if [[ -z "${!variable:-}" ]]; then
      echo "Defina a variavel secreta $variable antes de continuar." >&2
      exit 1
    fi
  done
}

echo "Ambiente configurado para $RESOURCE_GROUP em $LOCATION."
