#!/bin/bash

restore_config() {
echo
echo Restore config
cat <<EOF >.env
POSTGRES_DB=keycloak_db
POSTGRES_USER=keycloak_db_user
POSTGRES_PASSWORD=keycloak_db_user_password
KEYCLOAK_ADMIN=admin
EMAIL=CHANGE_ME
EOF
exit
}

program_exists() {
    type "$1" >/dev/null 2>&1
}


read_email() {
    read -p "Enter email: " -e email
    case "$email" in
        ""  )
            echo Error!!!
            echo Need correct e-mail
            exit
        ;;
        *   )
            sed -i '/EMAIL/d' .env
            echo EMAIL=$email >> .env
        ;;
    esac
}
if program_exists "docker"; then
    echo "Docker is installed."
    echo
else
    curl -fsSL https://get.docker.com -o get-docker.sh  
    sh get-docker.sh
fi

source .env
KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io
if [ "$#" -ge 3 ]
then
    echo Error!!!
    echo Too much parameters 
    exit

elif [ "$#" -eq 2 ]
then
    echo KC_HOSTNAME=$1 >> .env
    sed -i '/EMAIL/d' .env
    echo EMAIL=$2 >> .env
elif [ "$#" -eq 1 ]
then
    email=$(echo "$1" | awk '/@/{print $0}')
    if [ -n "$email" ]
    then
        echo KC_HOSTNAME=$KC_HOSTNAME >> .env
        sed -i '/EMAIL/d' .env
        echo EMAIL=$1 >> .env
    elif [ "$EMAIL" = "CHANGE_ME" ]
    then
        read_email
        echo KC_HOSTNAME=$1 >> .env
    fi
elif [ "$#" -eq 0 ]
then
    if [ "$EMAIL" = "CHANGE_ME" ]
    then
        read_email
        echo KC_HOSTNAME=$KC_HOSTNAME >> .env
    else
        echo KC_HOSTNAME=$KC_HOSTNAME >> .env
    fi
fi

clear
echo Check your config:
echo
cat .env
echo
read -p "Is congfig correct? [y/N]: " -e choice
case "$choice" in
    "" | "N" | "n"  )   restore_config;;
    "Y" | "y"       )   echo;;
    *               )
        echo Incorrect choice
        sleep 5
        restore_config
    ;;
esac
 
echo KEYCLOAK_ADMIN_PASSWORD=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 16) >> .env

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

echo Your configuration:
cat .env
source .env
echo
echo Keycloak is will be available in a minute at https://$KC_HOSTNAME
echo Username: $KEYCLOAK_ADMIN
echo Password: $KEYCLOAK_ADMIN_PASSWORD