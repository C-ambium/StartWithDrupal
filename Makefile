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

DOCKER_COMPOSE_FILES := -f docker-compose.yml -f docker-compose-dev.yml
ifneq ("$(wildcard docker-compose-dev-${OS_NAME}.yml)","")
DOCKER_COMPOSE_FILES := $(DOCKER_COMPOSE_FILES) -f docker-compose-dev-${OS_NAME}.yml
endif

ifneq ("$(wildcard docker-compose-local.yml)","")
DOCKER_COMPOSE_FILES := $(DOCKER_COMPOSE_FILES) -f docker-compose-local.yml
endif

DOCKER_COMPOSE = docker-compose ${DOCKER_COMPOSE_FILES}
EXEC_PHP = $(DOCKER_COMPOSE) exec -T php
DRUSH = $(EXEC_PHP) drush
COMPOSER = $(EXEC_PHP) composer
BUILD = $(DOCKER_COMPOSE) -f docker-compose-dev-tools.yml run --rm build
QA = $(DOCKER_COMPOSE) -f docker-compose-dev-tools.yml run --rm code_sniffer

.env:
ifeq (,$(wildcard ./.env))
	cp .env.dist .env
endif

##
## Project
## -------
##

build: ## Build project dependencies
build: .env	start
	$(BUILD) ./automation/bin/build.sh

kill:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans

install: ## Install and start the project
install: .env start
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/install.sh"
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/reset_password.sh"

update: ## Start and update the project
update: .env	start
	$(DOCKER_COMPOSE) exec php sh -c "./automation/bin/update.sh"

setup:  ## Install and start the project for other environments
setup: .env build install

reset: ## Stop and start a fresh install of the project
reset: kill install

start: update-permissions ## Start the project
	$(DOCKER_COMPOSE) up -d --remove-orphans
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /var/www/html/web/sites/default ]; then chmod -R a+w /var/www/html/web/sites/default; fi"
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /tmp/cache ]; then chmod -R a+w /tmp/cache; fi"

update-permissions: ## Fix permissions between Docker and the host
ifeq ($(OS_NAME), linux)
update-permissions:
	sudo setfacl -dR -m u:$(shell whoami):rwX -m u:82:rwX -m u:100:rX .
	sudo setfacl -R -m u:$(shell whoami):rwX -m u:82:rwX -m u:100:rX .
else ifeq ($(OS_NAME), mac)
update-permissions:
	sudo dseditgroup -o edit -a $(shell id -un) -t user $(shell id -gn 82)
endif

stop: ## Stop the project
	$(DOCKER_COMPOSE) stop

clean: ## Stop the project and remove generated files
clean: kill
	rm -rf .env vendor web/core web/modules/contrib web/themes/contrib web/profiles/contrib

ifeq (console,$(firstword $(MAKECMDGOALS)))
  CONSOLE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONSOLE_ARGS):;@:)
endif
console: ## Open a console in the passed container (e.g make console php)
	$(DOCKER_COMPOSE) exec $(CONSOLE_ARGS) bash

.PHONY: build setup setup-dev kill inst update reset start stop clean console update-permissions

##
## Utils
## -----
##
logs: ## Show drupal logs
	$(DRUSH) ws

cr: ## Clear the cache in dev env
	$(DRUSH) cache:rebuild

cex: ## Configuration export
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
code_sniffer: ## PHP_CodeSnifer (https://github.com/squizlabs/PHP_CodeSniffer)
	$(QA) ./automation/bin/code_sniffer.sh

.PHONY: code_sniffer

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help