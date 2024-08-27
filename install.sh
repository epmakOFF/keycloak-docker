#!/bin/bash

restore_config ()
{
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
exit
}

program_exists() {
    type "$1" >/dev/null 2>&1
}

generate_cert() {
    mkdir certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=TestOrg/OU=IT/CN=$KC_HOSTNAME/emailAddress=it@$KC_HOSTNAME"    
}

cert_dialog() {
    echo -n "Enter path to your certificate "
	    read -e cert
    if [ -s $cert ]
    then
        sed -i '/SSL_CERTIFICATE/d' .env
        echo SSL_CERTIFICATE=$cert >> .env
    else
        echo File not found!
        echo Abort!
        exit
    fi
    echo -n "Enter path to your private key "
        read -e privkey
    if [ -s $privkey ]
    then
        sed -i '/SSL_CERTIFICATE_KEY/d' .env
        echo SSL_CERTIFICATE_KEY=$privkey >> .env
    else
        echo File not found!
        echo Abort!
        exit
    fi
}

if program_exists "docker"; then
    echo "Docker is installed."
    echo
else
    curl -fsSL https://get.docker.com -o get-docker.sh  
    sh get-docker.sh
fi

KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io
echo -n "Enter your domain [$KC_HOSTNAME] "
	read -e domain
if [ "$domain" = "" ]
then
    sed -i '/KC_HOSTNAME/d' .env
    echo KC_HOSTNAME=$KC_HOSTNAME >> .env
else
    sed -i '/KC_HOSTNAME/d' .env
    echo KC_HOSTNAME=$domain >> .env
    KC_HOSTNAME=$domain
fi
echo
echo -n "Do you have certificate [y\N] "
	read -e have_cert
if [ "$have_cert" = "" ]
    then generate_cert
elif [ "$have_cert" = "n" ]
    then generate_cert
elif [ "$have_cert" = "N" ]
    then generate_cert
elif [ "$have_cert" = "y" ]
    then cert_dialog
elif [ "$have_cert" = "Y" ]
    then cert_dialog      
else
    echo Incorrect choice
    sleep 5
    exit
fi


clear
echo Check your config:
echo
cat .env
echo
echo -n "Is congfig correct? [y/N] "
	read -e choice
if [ "$choice" = "" ]
    then restore_config
elif [ "$choice" = "n" ]
    then restore_config
elif [ "$choice" = "N" ]
    then restore_config
elif [ "$choice" != "y" ]
    then
        if [ "$choice" != "Y" ]
            then
                echo Incorrect choice
                sleep 5
                restore_config
        fi
fi
 
echo KEYCLOAK_ADMIN_PASSWORD=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 16) >> .env
docker compose -f ./docker-compose.yaml up -d


echo Your configuration:
cat .env
source .env
echo
echo Keycloak is will be available in a minute at https://$KC_HOSTNAME
echo Username: $KEYCLOAK_ADMIN
echo Password: $KEYCLOAK_ADMIN_PASSWORD