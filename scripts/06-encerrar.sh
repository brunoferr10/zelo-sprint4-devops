#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
# Desaloca somente a VM. Disco e IP podem continuar gerando custo.
az vm deallocate -g "$VM_RG" -n "$VM_NAME"
# Depois da avaliacao, exclusao MANUAL e separada dos grupos:
# az group delete -n rg-zelo-s4-vm --yes
# az group delete -n rg-zelo-s4-webapp --yes
# Oracle FIAP nao e excluido por estes scripts.
