curl -fsSL https://get.docker.com -o get-docker.sh  
sh get-docker.sh

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt


export KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io  
docker compose up
