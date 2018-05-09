OS_INFORMATION=$(shell uname -s)
ifneq (,$(findstring Linux,$(OS_INFORMATION)))
OS_NAME			= linux
endif

ifneq (,$(findstring Darwin,$(OS_INFORMATION)))
OS_NAME			= mac
endif

ifneq (,$(findstring CYGWIN,$(OS_INFORMATION)))
OS_NAME			= win
endif

ifneq (,$(findstring MINGW,$(OS_INFORMATION)))
OS_NAME			= win
endif

DOCKER_COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml
ifneq ("$(wildcard docker-compose-dev-${OS_NAME}.yml)","")
DOCKER_COMPOSE_FILES = -f docker-compose.yml -f docker-compose-dev.yml -f docker-compose-dev-${OS_NAME}.yml
endif

DOCKER_COMPOSE  = docker-compose ${DOCKER_COMPOSE_FILES}

EXEC_PHP        = $(DOCKER_COMPOSE) exec -T php

DRUSH         	= $(EXEC_PHP) drush
COMPOSER        = $(EXEC_PHP) composer

BUILD	= $(DOCKER_COMPOSE) -f docker-compose-dev-tools.yml run --rm build
QA        = $(DOCKER_COMPOSE) -f docker-compose-dev-tools.yml run --rm code_sniffer

.env: .env.dist
	@if [ -f .env ]; \
	then\
		echo '\033[1;41m/!\ The .env.dist file has changed. Please check your .env file (this message will not be displayed again).\033[0m';\
		touch .env;\
		exit 1;\
	else\
		echo cp .env.dist .env;\
		cp .env.dist .env;\
	fi

##
## Project
## -------
##

build: ## Build project dependencies
build: .env	start
	$(BUILD) ./automation/bin/build.sh

build-dev: ## Build project dependencies for development
build-dev: .env	start
	$(BUILD) ./automation/bin/build.sh --mode dev

kill:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans

inst: ## Install and start the project
ifeq ($(OS_NAME), win)
inst:
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "./automation/bin/install.sh"
else
inst:
	$(DOCKER_COMPOSE) exec -T php sh -c "./automation/bin/install.sh"
endif

setup:  ## Install and start the project for other environments
setup: .env build start inst

setup-dev:  ## Install and start the project for development
setup-dev: .env build-dev start inst
	docker-compose exec php sh -c "./automation/bin/reset_password.sh"

reset: ## Stop and start a fresh install of the project
reset: kill inst

start: ## Start the project
	@if [ ${OS_NAME} == 'linux' ]; \
	then\
		sudo setfacl -dR -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./;\
		sudo setfacl -R -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./;\
	elif [ ${OS_NAME} == 'mac' ]; \
	then\
		sudo dseditgroup -o edit -a $(id -un) -t user $(id -gn 82);\
	fi;\
	$(DOCKER_COMPOSE) up -d --remove-orphans;\
	$(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /var/www/html/web/sites/default ]; then chmod -R a+w /var/www/html/web/sites/default; fi";\
    $(DOCKER_COMPOSE) exec -u 0 php sh -c "if [ -d /tmp/cache ]; then chmod -R a+w /tmp/cache; fi";\

stop: ## Stop the project
	$(DOCKER_COMPOSE) stop

clean: ## Stop the project and remove generated files
clean: kill
	rm -rf .env vendor

ifeq (console,$(firstword $(MAKECMDGOALS)))
  CONSOLE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONSOLE_ARGS):;@:)
endif
console: ## Open a console in the passed container (e.g make console php)
	$(DOCKER_COMPOSE) exec $(CONSOLE_ARGS) bash

.PHONY: build build-dev setup setup-dev kill inst reset start stop clean console

##
## Utils
## -----
##
logs: ## Show drupal logs
	$(DRUSH) ws

cr: ## Clear the cache in dev env
	$(DRUSH) cache:rebuild

ifeq (composer,$(firstword $(MAKECMDGOALS)))
  COMPOSER_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMPOSER_ARGS):;@:)
endif
composer: ## Execute a composer command inside PHP container (e.g: make composer require drupal/paragraphs)
	$(COMPOSER) $(COMPOSER_ARGS)

.PHONY: logs cr composer

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
