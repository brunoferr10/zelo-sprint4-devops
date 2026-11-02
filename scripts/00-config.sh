#!/usr/bin/env bash
set -euo pipefail
export LOCATION="${LOCATION:-canadacentral}"
export VM_RG="rg-zelo-s4-vm"
export VM_NAME="vm-zelo-sprint4"
export VM_USER="bruno"
export VM_SIZE="${VM_SIZE:-Standard_B2s}"
export APP_RG="${APP_RG:-rg-zelo-s4-webapp}"
export WEB_APP_NAME="${WEB_APP_NAME:-zelo-s4-rm563489}"
export APP_PLAN="plan-zelo-s4"
export APP_SKU="${APP_SKU:-B1}"
