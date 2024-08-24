#!/bin/bash
if [ -n "$1" ]
then
echo KC_HOSTNAME=$1 >> .env
else
echo KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io >> .env
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
0 5  * * *  $(pwd)/cron_job.sh
EOF

crontab ./crontab
docker compose -f ./docker-compose.yaml up -d
