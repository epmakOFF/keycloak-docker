## Разворачиваем собсственный IdP
Содержание:  
* Самоподписанный/собственный сертификат  
    * [Подготовка](#preparing)
    * [Настройка](#tuning)  
* Сертификат от Let’s Encrypt
    * [Установка и запуск](#deploy)

## Самоподписанный/собственный сертификат  
### Подготовка <a id="preparing"/></a>
#### Для ленивых
Клонировать репозиторий
``` bash
git clone https://github.com/epmakOFF/keycloak-docker.git
cd keycloak-docker
```  
(При наличии)  
Подготовить файл сертификата и приватный ключ

Запустить скрипт
``` bash
chmod +x install.sh
sudo ./install.sh
```
#### Для упертых
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
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=TestOrg/OU=IT/CN=$KC_HOSTNAME/emailAddress=it@$KC_HOSTNAME"
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


## Сертификат от Let’s Encrypt  
### Подготовка <a id="deploy"/></a>
Клонировать репозиторий
``` bash
git clone https://github.com/epmakOFF/keycloak-docker.git
cd keycloak-docker/v2
```

Сделать скрипты исполняемыми
``` bash
chmod +x *.sh
```
(Опционально)  
Изменить парамерты доступа к БД, логин администратора и email в файле `.env`

### Запуск  
Выполнить установку, в качестве параметров передать домен и email. Если домен не задан, будет использован `ip`.sslip.io. Email должен быть определен в `.env`. Примеры запуска:
``` bash
sudo ./install.sh  # задан email в .env, в качестве домена используется ip.sslip.io
```
``` bash
sudo ./install.sh admin@example.org # в качестве домена используется ip.sslip.io
```
``` bash
sudo ./install.sh sso.examle.org admin@example.org # переданы оба значения
```