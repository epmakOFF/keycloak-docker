#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh  
sh get-docker.sh

if [ -n "$1" ]
then
echo KC_HOSTNAME=$1 >> .env
else
echo KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io >> .env
fi

if [ -n "$2" ]
then
sed -i '/EMAIL/d' .env
echo EMAIL=$2 >> .env
else
source .env
if [ "$EMAIL" = "CHANGE_ME" ]
then
echo Need correct e-mail
exit
fi
fi
 
# Phase 1
docker compose -f ./docker-compose-initiate.yaml up -d nginx
docker compose -f ./docker-compose-initiate.yaml up certbot
docker compose -f ./docker-compose-initiate.yaml down
 
# some configurations for let's encrypt
curl -L --create-dirs -o letsencrypt/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
openssl dhparam -out letsencrypt/ssl-dhparams.pem 2048
 
# Phase 2
cat <<EOF >./crontab
# m h  dom mon dow   command
0 0 1 * * $(pwd)/cron_job.sh
EOF

crontab ./crontab
docker compose -f ./docker-compose.yaml up -d
