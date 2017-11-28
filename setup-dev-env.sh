#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

source .env

docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d

docker-compose -f docker-compose.yml -f docker-compose-dev.yml exec -u root php sh -c "chmod -R a+w /var/www/html/web/sites/default"
docker-compose -f docker-compose.yml -f docker-compose-dev.yml exec -u root php sh -c "chmod -R a+w /tmp/cache"

docker-compose exec php ./automation/bin/build.sh --mode dev

set +e
docker-compose exec -u $(id -u):$(id -g) php composer prepare-settings
set -e

docker-compose exec -u $(id -u):$(id -g) php ./automation/bin/install.sh

docker-compose exec -u $(id -u):$(id -g) php ./automation/bin/reset_password.sh