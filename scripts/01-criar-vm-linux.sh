#!/usr/bin/env bash
# Executar no Cloud Shell Bash. Cria a VM de trabalho e hospedagem do banco MySQL.
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
: "${SSH_SOURCE_CIDR:?Defina SSH_SOURCE_CIDR com seu IP publico/32}"
: "${SSH_PUBLIC_KEY_FILE:?Defina o caminho de uma chave publica SSH .pub}"
test -s "$SSH_PUBLIC_KEY_FILE"
python3 -c 'import ipaddress,sys; n=ipaddress.ip_network(sys.argv[1],strict=True); assert n.version==4 and n.prefixlen==32 and n.network_address.is_global, "Use seu IPv4 publico com /32"' "$SSH_SOURCE_CIDR"
az account show --query '{assinatura:name,id:id}' -o table
if ! az group show -n "$VM_RG" -o none 2>/dev/null; then
  az group create -n "$VM_RG" -l "$LOCATION" -o none
fi
az network nsg create -g "$VM_RG" -n zelo-s4-vm-nsg -l "$LOCATION" -o none
az network nsg rule create -g "$VM_RG" --nsg-name zelo-s4-vm-nsg -n SSH-do-aluno \
 --priority 1000 --access Allow --protocol Tcp --direction Inbound \
 --source-address-prefixes "$SSH_SOURCE_CIDR" --destination-port-ranges 22 -o none
az vm create -g "$VM_RG" -n "$VM_NAME" -l "$LOCATION" \
 --image Canonical:ubuntu-24_04-lts:server:latest --size "$VM_SIZE" \
 --admin-username "$VM_USER" --authentication-type ssh --ssh-key-values "$SSH_PUBLIC_KEY_FILE" \
 --nsg zelo-s4-vm-nsg --nsg-rule NONE --public-ip-sku Standard \
 --storage-sku StandardSSD_LRS --os-disk-size-gb 32 -o none
IP=$(az vm show -d -g "$VM_RG" -n "$VM_NAME" --query publicIps -o tsv)
echo "Conecte do computador cuja chave publica foi fornecida: ssh $VM_USER@$IP"
echo "Mantenha esta VM ligada enquanto o Web App depender do MySQL nela."
