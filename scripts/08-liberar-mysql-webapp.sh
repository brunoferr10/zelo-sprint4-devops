#!/usr/bin/env bash
# Na VM ou Cloud Shell com az login. Obtem origens diretamente do Web App.
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
ips=$(az webapp show -g "$APP_RG" -n "$WEB_APP_NAME" --query possibleOutboundIpAddresses -o tsv)
[[ -n "$ips" && "$ips" != "null" ]] || { echo "Web App sem lista de IPs; nenhuma regra alterada."; exit 1; }
IFS=',' read -r -a origens <<< "$ips"
az network nsg rule create -g "$VM_RG" --nsg-name zelo-s4-vm-nsg -n MySQL-WebApp \
 --priority 1100 --access Allow --protocol Tcp --direction Inbound \
 --source-address-prefixes "${origens[@]}" --destination-port-ranges 3306 -o none
echo "Regra MySQL-WebApp atualizada somente com os IPs de saida possiveis do Web App."
