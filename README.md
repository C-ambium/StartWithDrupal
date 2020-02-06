Start With Drupal 8
===================

Sandbox to increase skills and familiarize with Drupal 8 & Drush 9.

### Build in progress ...

Workspace Tools
---------------

* Ubuntu 19.10.2
* Drupal 8
* Drush 9
* PHP 7.3.11
* Docker 19.03.3 (Varnish, Crond, Traefik)
* Symfony
* Composer
* Maestro
--- 
  
# Application Drupal  

## Prérequis

Pour utiliser ce socle, il faut au préalable avoir suivi toutes les étapes d'installation de docker.

## Environnement de dev  

### Setup
  
Pour installer le projet, exécuter la commande suivante :

```bash  
make setup
```  

### Autres commandes

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
  
```
 Project
 -------

build                          Build project dependencies.
kill                           Kill all docker containers.
install                        Start docker stack and install the project.
update                         Start docker stack and update the project.
setup                          Start docker stack, build and install the project.
reset                          Kill all docker containers and start a fresh install of the project.
start                          Start the project.
reset_password                 Reset the Drupal password to "admin".
update-permissions             Fix permissions between Docker and the host.
stop                           Stop all docker containers.
clean                          Kill all docker containers and remove generated files
console                        Open a console in the container passed in argument (e.g make console php)

 Utils
 -----

logs                           Show Drupal logs.
cr                             Rebuild Drupal caches.
cex                            Ecport Drupal configuration.
composer                       Execute a composer command inside PHP container (e.g: make composer require drupal/paragraphs)

 Quality assurance
 -----------------

code_sniffer                   Run PHP Code Sniffer using the phpcs.xml.dist ruleset.
security_check                 Search for vulnerabilities into composer.lock.
```  
