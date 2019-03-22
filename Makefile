OS_INFORMATION=$(shell uname -s)
ifneq (,$(findstring Linux,$(OS_INFORMATION)))
OS_NAME = linux
endif

ifneq (,$(findstring Darwin,$(OS_INFORMATION)))
OS_NAME = mac
endif

ifneq (,$(findstring CYGWIN,$(OS_INFORMATION)))
OS_NAME = win
endif

ifneq (,$(findstring MINGW,$(OS_INFORMATION)))
OS_NAME = win
endif

DOCKER_COMPOSE_FILES := -f docker-compose.yml
ifneq ("$(wildcard docker-compose-${OS_NAME}.yml)","")
DOCKER_COMPOSE_FILES := $(DOCKER_COMPOSE_FILES) -f docker-compose-${OS_NAME}.yml
endif

ifneq ("$(wildcard docker-compose-local.yml)","")
DOCKER_COMPOSE_FILES := $(DOCKER_COMPOSE_FILES) -f docker-compose-local.yml
endif

DOCKER_COMPOSE = docker-compose ${DOCKER_COMPOSE_FILES}
EXEC_PHP = $(DOCKER_COMPOSE) exec -T php
DRUSH = $(EXEC_PHP) drush
COMPOSER = $(EXEC_PHP) composer

.env:
ifeq (,$(wildcard ./.env))
	cp .env.dist .env
endif

##
## Project
## -------
##

build: ## Build project dependencies.
build: .env	start
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/build.sh"

kill: ## Kill all docker containers.
kill:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans

install: ## Start docker stack and install the project.
install: .env start
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/install.sh"
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/reset_password.sh"

update: ## Start docker stack and update the project.
update: .env	start
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/update.sh"

setup:  ## Start docker stack, build and install the project.
setup: .env build install

reset: ## Kill all docker containers and start a fresh install of the project.
reset: kill setup

start: update-permissions ## Start the project.
	$(DOCKER_COMPOSE) up -d --remove-orphans
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /var/www/html/web/sites/default ]; then chmod -R a+w /var/www/html/web/sites/default; fi"
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /tmp/cache ]; then chmod -R a+w /tmp/cache; fi"


reset_password: ## Reset the Drupal password to "admin".
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/reset_password.sh"

update-permissions: ## Fix permissions between Docker and the host.
ifeq ($(OS_NAME), linux)
update-permissions:
	sudo setfacl -dR -m u:$(shell whoami):rwX -m u:82:rwX -m u:100:rX .
	sudo setfacl -R -m u:$(shell whoami):rwX -m u:82:rwX -m u:100:rX .
else ifeq ($(OS_NAME), mac)
update-permissions:
	sudo dseditgroup -o edit -a $(shell id -un) -t user $(shell id -gn 82)
endif

stop: ## Stop all docker containers.
	$(DOCKER_COMPOSE) stop

clean: ## Kill all docker containers and remove generated files
clean: kill
	rm -rf .env vendor web/core web/modules/contrib web/themes/contrib web/profiles/contrib

ifeq (console,$(firstword $(MAKECMDGOALS)))
  CONSOLE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONSOLE_ARGS):;@:)
endif
console: ## Open a console in the container passed in argument (e.g make console php)
	$(DOCKER_COMPOSE) exec $(CONSOLE_ARGS) bash

.PHONY: build setup kill install update reset reset_password start stop clean console update-permissions

##
## Utils
## -----
##
logs: ## Show Drupal logs.
	$(DRUSH) ws

cr: ## Rebuild Drupal caches.
	$(DRUSH) cache:rebuild

cex: ## Ecport Drupal configuration.
	$(DRUSH) config-split:export -y

ifeq (composer,$(firstword $(MAKECMDGOALS)))
  COMPOSER_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMPOSER_ARGS):;@:)
endif
composer: ## Execute a composer command inside PHP container (e.g: make composer require drupal/paragraphs)
	$(COMPOSER) $(COMPOSER_ARGS)

.PHONY: logs cr cex composer

##
## Quality assurance
## -----------------
##
code_sniffer: ## Run PHP Code Sniffer using the phpcs.xml.dist ruleset.
	$(DOCKER_COMPOSE) -f docker-compose-tools.yml run --rm php_quality_tools phpcs --standard=phpcs.xml.dist

security_check: ## Search for vulnerabilities into composer.lock.
	$(DOCKER_COMPOSE) -f docker-compose-tools.yml run --rm php_quality_tools security-checker security:check --timeout=30 ./composer.lock

.PHONY: code_sniffer security_check

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
