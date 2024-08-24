## Разворачиваем собсственный IdP
Содержание:  
* [Подготовка](#preparing)
* [Настройка](#tuning)


### Подготовка <a id="preparing"/></a>
Клонировать репозиторий
``` bash
git clone https://github.com/epmakOFF/keycloak-docker.git
cd keycloak-docker
```

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

### Настройка <a id="tuning"/></a>
Переопределить переменные в файле `.env`.  
Если не задан домен в `.env`, взять публичный:  
``` bash
export KC_HOSTNAME=$(curl -s 2ip.ru).sslip.io  
```

#### Нет сертификата  
Для выпуска самоподписанного сертификата выполнить:  
``` bash
mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt
```

Выполнить запуск:
``` bash
docker compose up -d
```

#### Есть сертификат  
Переопределить переменные `SSL_CERTIFICATE` и `SSL_CERTIFICATE_KEY` в файле `.env`, указав путь до сертификата и приватного ключа  
Выполнить запуск:
``` bash
docker compose up -d
```
