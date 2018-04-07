[![pipeline status](https://gitlab.niji.fr/niji-tools/socles/app-drupal-docker/badges/master/pipeline.svg)](https://gitlab.niji.fr/niji-tools/socles/app-drupal-docker/commits/master)

# Application Drupal

Ce socle applicatif est totalement découplée de tout hébergement.
Il peut être utilisé dans un environnement LAMP, tout comme dans un environnement docker par exemple.

**Remarque**: Vous pouvez utiliser docker pour votre de developpement. Cepandant, il faut installer le reverse proxy est créer le network avant de lancer l'ennvironnement.
Voir: https://gitlab.niji.fr/niji-tools/socles/docker-dev-host
Ensuite, sur votre machine lancer le script setup-dev-env

## Environnement de dev

Ci-dessous comment lancer votre environnement de developpement

Sur votre environnement Linux ou MAC OS:

```bash
make setup-dev
```

## Lignes de commandes

Un certain nombre d'outils accessibles en ligne de commande sont disponible par l'intermédiaire d'un Makefile à la racine, qui peut être complété selon les besoins de chaque projet.

Pour lister l'ensemble des commandes disponibles, il suffit d'executer la commande:

```bash
make
```

Les commandes s'exécutent comme suit:

```bash
make [commande]
``` 

Liste des commandes par défaut:

```bash
 Project
 -------

build                          Build project dependencies
build-dev                      Build project dependencies for development
inst                           Install and start the project
setup                          Install and start the project for other environments
setup-dev                      Install and start the project for development
reset                          Stop and start a fresh install of the project
start                          Start the project
stop                           Stop the project
clean                          Stop the project and remove generated files
console                        Open a console in the passed container (e.g make console php)

 Utils
 -----

logs                           Show drupal logs
cr                             Clear the cache in dev env
composer                       Execute a composer command inside PHP container (e.g: make composer require drupal/paragraphs)

 Quality assurance
 -----------------

code_sniffer                   PHP_CodeSnifer (https://github.com/squizlabs/PHP_CodeSniffer)
```

## Permissions

Pour éviter les problèmes de permissions potentiels entre la machine hôte et les conteneurs (par exemple can't access files generated by PHP), utiliser le mécanisme des ACL, disponible sur la plupart des distributions Linux.

Au niveau de votre répertoire applicatif, lancer la commande suivante :

```bash
sudo setfacl -dR -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./
sudo setfacl -R -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./
```


**Sources**: https://github.com/wodby/docker4drupal/blob/master/docs/permissions.md


## Artifactory

Après avoir fait une demande de creation repos, vous avez les informations suivantes :

```
Add to gitlab secret variables :

ARTIFACTORY_GENERIC_LOCAL_REPO_URL: https://artifactory.niji.delivery/artifactory/niji-socles-generic
ARTIFACTORY_GENERIC_LOCAL_CLIENT_REPO_URL: https://artifactory.niji.delivery/artifactory/niji-socles-generic-client
ARTIFACTORY_DOCKER_LOCAL_CLIENT_REGISTERY_URI: niji-socles-docker-client.artifactory.niji.delivery
ARTIFACTORY_DOCKER_VIRTUAL_REGISTERY_URI: niji-socles-virtual-docker.artifactory.niji.delivery
ARTIFACTORY_USER: niji-socles-publisher
ARTIFACTORY_PASSWORD: SuQkJoZP5

Send to the client for delivery :

ARTIFACTORY_URL: https://artifactory.niji.delivery
ARTIFACTORY_DOCKER_REGISTERY_URI: niji-socles-docker-client.artifactory.niji.delivery
ARTIFACTORY_GENERIC_REPO_URL: https://artifactory.niji.delivery/artifactory/niji-socles-generic-client
ARTIFACTORY_USER: niji-socles-client
ARTIFACTORY_PASSWORD: m6t3EdzYGZP
```

## Paramètres

## Installation / Mise à jour

### Build

`./automation/bin/build.sh`

Ajouter la paramètre `--mode dev` pour une inclure les dépendances de développement.

### Installation

`./automation/bin/install.sh`

Attention, la base de donnée est supprimée lors de chaque installation.

### Mise à jour

`./automation/bin/update.sh`

## Divers

### Reconstruire les paramètres

`composer prepare-settings`

### Code sniffer

`./automation/bin/code_sniffer.sh`

### Reset password

`./automation/bin/reset_password.sh`


# Comment tester le deploiement on mode run

## Initialiser l'environnement


Lancer les commandes suiventes, cela permet d'arrêter l'envirennment en mode dev et s'authentifier à votre registery artifactory

```bash
docker-compose down
...
export ARTIFACTORY_DOCKER_VIRTUAL_REGISTERY_URI="niji-socle-drupal-docker.artifactory.niji.delivery"
export PHP_DOCKER_IMAGE_NAME="niji-tools-socles-app-drupal-docker-php"
export APACHE_DOCKER_IMAGE_NAME="niji-tools-socles-app-drupal-docker-apache"
export CI_COMMIT_REF_SLUG="master"
export COMPOSE_PROJECT_NAME="test"
export APP_DOMAIN=test.socles.niji.delivery

docker login ${ARTIFACTORY_DOCKER_VIRTUAL_REGISTERY_URI}
Username: niji-socle
Password:
Login Succeeded
```

Ensuite, lancer l'environment en mode run:

```bash
docker-compose -f docker-compose.yml -f docker-compose-deploy.yml up -d
```

Enfin, il nous reste l'installation:

```bash
docker-compose exec php ./automation/bin/install.sh
```
