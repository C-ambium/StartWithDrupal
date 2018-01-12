# Présentaion

## Objectifs du document

Ce document a pour objectif de décrire les procédures d’installation te d'exploitaion de application “{{ APP_NAME }}” sur une plateforme docker.

Le document contient les éléments suivants :
-	la procédure d’installation et de configuration des containers Php et Apache
-	la procédure d’installation de l’application “{{ APP_NAME }}”

# Livrable

Le livrable est composé d'un document contenant les informations suivantes :
  * APP_TAG
  * PHP_DOCKER_IMAGE_NAME
  * APACHE_DOCKER_IMAGE_NAME
  * ARTIFACTORY_DOCKER_REGISTERY_URI
  * ARTIFACTORY_GENERIC_REPO_URL
  * ARTIFACTORY_USER
  * ARTIFACTORY_PASSWORD

# Liste des paramètres d’installation

Les éléments paramétrables (obligatoirs) dans les procédures d’installation sont référencés dans le tableau ci-dessous.

Par convention le nom du paramètre est indiqué de la façon suivante : ${NOM_DU_PARAMETRE}.

| Paramètre                        | Définition                                     |
|-----------                       |------------                                    |
| APP_NAME                         | le nom de l'application                        |
| APP_TAG                          | la version de la application livré (ex: 1.0.1) |
| PHP_DOCKER_IMAGE_NAME            | le nom de l'image docker Php livré             |
| APACHE_DOCKER_IMAGE_NAME         | le nom de l'image docker Apache livré          |
| ARTIFACTORY_DOCKER_REGISTERY_URI | l'uri du registery docker artifactory          |
| ARTIFACTORY_GENERIC_REPO_URL     | l'url de repo artifactory contenant le tar.gz  |
| ARTIFACTORY_USER                 | le nom de l'utilisateur artifactory            |
| ARTIFACTORY_PASSWORD             | le mot de pass de l'utilisateur artifactory    |
| SMTP_HOST                        | l'adresse du serveur SMTP                      |
| SMTP_PORT                        | le port du service SMTP                        |
| SMTP_USER                        | l'utilisateur d'authentication SMTP            |
| SMTP_PASSWORD                    | le password d'authentication SMTP              |
| REDIS_HOST                       | l'adresse du serveur REDIS                     |
| DB_HOST                          | l'adresse de la base de données                |
| DB_NAME                          | le nom de  la base de données                  |
| DB_USER                          | le nom de l'utilisateur                        |
| APP_HASH_SALT                    | hash de salage des passwords applicatif        |
| APACHE_BACKEND_HOST              | L'adresse du serveru php fpm                   |
| APACHE_SERVER_NAME               | le nom de domaine de l'application             |


Les images docker livrées (php et apache) sont basé sur des images wodby. Ces dernière donnents la possiblité de customiser des variables supplémentaires que vous pouvez consulter dans leurs github respectives :
 - Apache : https://github.com/wodby/php-apache
 - Php : https://github.com/wodby/php


# Deployer des conteneurs Php Apache

La procédure ci-dessous permet le deploiement des conteneurs docker __de manière natif__, à l'aide de la commande ```docker run```. Ainsi, ce qui suivera est __à titre indicatif__, libre à vous d'utiliser d'autres methodes de deploiement (swarm, __kubernetes__, ...) et de stockage (Ceph, Gluster Fs , NFS, ...).

## Creation du volume de stockage

Créer un volume de stockage applé ${APP_NAME}_shared. Ce dernier contiendera les fichiers "uploadés" hors conteneurs.

```bash
docker volume create ${APP_NAME}_shared
```
__Attention: la création de volume ne permet pas une scalabilité horizontal dans un cluster__

## Deploiement du conteneur Php

Executer la commande suivante pour s'authentifier au registery docker :

```bash
docker login ${ARTIFACTORY_DOCKER_REGISTERY_URI}
Username: ${ARTIFACTORY_USER}
Password: ${ARTIFACTORY_PASSWORD}
Login Succeeded
```

Ensuite, lancer le deploiment le conteneur Php et l'installation de l'application:

```bash
sudo docker run -d \
-e PHP_SENDMAIL_PATH="/usr/sbin/sendmail -t -i -S ${SMTP_HOST}:${SMTP_PORT}" \
-e PHP_FPM_CLEAR_ENV="no" \ # pass env var to Php-fpm
-e DB_HOST="${DB_HOST}" \
-e DB_NAME="${DB_NAME}" \
-e DB_USER="${DB_USER}" \
-e DB_PASSWORD="${DB_PASSWORD}" \
-e REDIS_HOST="${REDIS_HOST}" \
-e APP_HASH_SALT="${APP_HASH_SALT}" \
--volume ${APP_NAME}_shared:/var/www/html/web/sites/default/files \
--workdir /var/www/html \
${ARTIFACTORY_DOCKER_REGISTERY_URI}/${PHP_DOCKER_IMAGE_NAME}:${APP_TAG} \
./automation/bin/install.sh
```

Lancer le deploiement du contenaire Apache:

```bash
sudo docker run -d \
-e APACHE_LOG_LEVEL="error" \
-e APACHE_BACKEND_HOST="${APACHE_BACKEND_HOST}" \
-e APACHE_SERVER_ROOT="/var/www/html/web" \
-e APACHE_SERVER_NAME="default" \
--volume ${APP_NAME}_shared:/var/www/html/web/sites/default/files \
--workdir /var/www/html \
${ARTIFACTORY_DOCKER_REGISTERY_URI}/${APACHE_DOCKER_IMAGE_NAME}:${APP_TAG}
```
