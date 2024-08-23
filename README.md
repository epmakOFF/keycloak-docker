curl -fsSL https://get.docker.com -o get-docker.sh  
sh get-docker.sh

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt

export KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io  
docker compose up
