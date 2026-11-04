#!/usr/bin/env bash
# Apenas para NOVA instalacao na VM Ubuntu. Nao recria o container existente.
set -euo pipefail
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
if sudo docker container inspect zelo-mysql >/dev/null 2>&1; then
  echo "Container zelo-mysql ja existe. Nenhum dado ou configuracao alterado."
  sudo docker ps -a --filter name=^/zelo-mysql$
  exit 0
fi
if sudo docker volume inspect zelo-mysql-data >/dev/null 2>&1; then
  echo "Volume existente: revise recuperacao antes de criar outro container. Nada alterado."
  exit 1
fi
sudo -v
umask 077
secret_dir=$(mktemp -d)
trap 'rm -rf "$secret_dir"; unset MYSQL_ROOT_PASSWORD MYSQL_PASSWORD' EXIT
read -r -s -p "Nova senha root MySQL: " MYSQL_ROOT_PASSWORD; echo
read -r -s -p "Nova senha zelo_user MySQL: " MYSQL_PASSWORD; echo
: "${MYSQL_ROOT_PASSWORD:?Senha root vazia}"
: "${MYSQL_PASSWORD:?Senha do usuario vazia}"
printf 'MYSQL_ROOT_PASSWORD=%s\nMYSQL_PASSWORD=%s\nMYSQL_DATABASE=zelo\nMYSQL_USER=zelo_user\n' "$MYSQL_ROOT_PASSWORD" "$MYSQL_PASSWORD" > "$secret_dir/mysql.env"
sudo docker volume create zelo-mysql-data >/dev/null
sudo docker run -d --name zelo-mysql --restart unless-stopped \
 --env-file "$secret_dir/mysql.env" -p 3306:3306 \
 -v zelo-mysql-data:/var/lib/mysql mysql:8.4 >/dev/null
echo "Aguarde ready for connections em: sudo docker logs --tail 30 zelo-mysql"
echo "Depois abra mysql -u zelo_user -p zelo no container e importe script_bd.sql."
