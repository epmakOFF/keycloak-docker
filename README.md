Установить Docker
``` bash
curl -fsSL https://get.docker.com -o get-docker.sh  
sudo sh get-docker.sh
```

Добавить пользователя в группу docker
``` bash
sudo usermod -aG docker $USER
sg docker # обновить права на группу, если не получится, перелогиниться
```
Переопределить переменные в файле `.env`, для выпуска самоподписанного сертификата выполнить:  
``` bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt
```

Если не задан домен в `.env`, взять публичный:
``` bash
export KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io  
```

Выполнить запуск:
``` bash
docker compose up -d
```