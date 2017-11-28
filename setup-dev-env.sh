#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

source .env

sudo setfacl -dR -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./
sudo setfacl -R -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./

docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d

sudo chmod +w ./web/sites/default -R

docker-compose exec php ./automation/bin/build.sh --mode dev

set +e
docker-compose exec -u $(id -u):$(id -g) php composer prepare-settings
set -e

docker-compose exec -u $(id -u):$(id -g) php ./automation/bin/install.sh

docker-compose exec -u $(id -u):$(id -g) php ./automation/bin/reset_password.sh