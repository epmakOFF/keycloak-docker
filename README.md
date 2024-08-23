curl -fsSL https://get.docker.com -o get-docker.sh  
sh get-docker.sh

export KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io  
docker compose up
