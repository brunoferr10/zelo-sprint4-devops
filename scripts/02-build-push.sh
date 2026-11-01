#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-configurar-ambiente.sh"
az acr build --registry "$ACR_NAME" --image "$DB_IMAGE:v1" --file docker/db/Dockerfile . --no-logs --output none
