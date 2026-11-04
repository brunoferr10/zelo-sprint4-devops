#!/usr/bin/env bash
# Somente depois da avaliacao. A VM hospeda o banco: desliga-lo interrompe o app.
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
if [[ "${ENCERRAR_APOS_AVALIACAO:-}" != "SIM" ]]; then
  echo "Nenhuma alteracao. A VM hospeda o MySQL. Apos a avaliacao, defina ENCERRAR_APOS_AVALIACAO=SIM."
  exit 0
fi
az vm deallocate -g "$VM_RG" -n "$VM_NAME"
echo "VM desalocada; banco indisponivel. Plano Web App, disco e IP podem continuar gerando custo."
# Exclusao definitiva dos grupos e volumes nao e automatizada aqui.
