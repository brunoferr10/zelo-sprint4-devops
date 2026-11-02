#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
HOST=$(az webapp show -g "$APP_RG" -n "$WEB_APP_NAME" --query defaultHostName -o tsv)
for attempt in {1..36}; do
 if curl -fsS "https://$HOST/actuator/health"; then
  echo; echo "App: https://$HOST/"; echo "Swagger: https://$HOST/swagger-ui/index.html"; exit 0
 fi
 sleep 10
done
exit 1
