#!/bin/bash

restore_config() {
echo
echo Restore config
cat <<EOF >.env
POSTGRES_DB=keycloak_db
POSTGRES_USER=keycloak_db_user
POSTGRES_PASSWORD=keycloak_db_user_password
KEYCLOAK_ADMIN=admin
KC_HOSTNAME=\${KC_HOSTNAME}
SSL_CERTIFICATE=./certs/nginx-selfsigned.crt
SSL_CERTIFICATE_KEY=./certs/nginx-selfsigned.key
EOF
exit 0
}

program_exists() {
    type "$1" >/dev/null 2>&1
}

generate_cert() {
    mkdir certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=TestOrg/OU=IT/CN=$KC_HOSTNAME/emailAddress=it@$KC_HOSTNAME"    
}

cert_dialog() {
    echo -n "Enter path to your certificate: "
	    read -e cert
    if [ -s $cert ]
    then
        sed -i '/SSL_CERTIFICATE/d' .env
        echo SSL_CERTIFICATE=$cert >> .env
    else
        echo File not found!
        echo Abort!
        exit 126
    fi
    echo -n "Enter path to your private key: "
        read -e privkey
    if [ -s $privkey ]
    then
        sed -i '/SSL_CERTIFICATE_KEY/d' .env
        echo SSL_CERTIFICATE_KEY=$privkey >> .env
    else
        echo File not found!
        echo Abort!
        exit 126
    fi
}

if program_exists "docker"; then
    echo "Docker is installed."
    echo
else
    curl -fsSL https://get.docker.com -o get-docker.sh  
    sh get-docker.sh
fi
# Get domain
KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io
read -p "Enter your domain [$KC_HOSTNAME]: " -e domain
case "$domain" in
    ""  ) 
        sed -i '/KC_HOSTNAME/d' .env
        echo KC_HOSTNAME=$KC_HOSTNAME >> .env
    ;;
    *   )
        sed -i '/KC_HOSTNAME/d' .env
        echo KC_HOSTNAME=$domain >> .env
        KC_HOSTNAME=$domain
    ;;
esac

echo
read -p "Do you have certificate [y\N]: " -e have_cert
case "$have_cert" in
    "" | "N" | "n"  )   generate_cert;;
    "Y" | "y"       )   cert_dialog;;
    *               )
        echo Incorrect choice
        sleep 5
        exit 22
    ;;
esac


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
docker compose -f ./docker-compose.yaml up -d


echo Your configuration:
cat .env
source .env
echo
echo Keycloak is will be available in a minute at https://$KC_HOSTNAME
echo Username: $KEYCLOAK_ADMIN
echo Password: $KEYCLOAK_ADMIN_PASSWORD