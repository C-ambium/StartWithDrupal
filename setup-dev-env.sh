#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

source .env

OS_INFORMATION="$(uname -s)"
case "${OS_INFORMATION}" in
    Linux*)     OS_NAME=linux;;
    Darwin*)    OS_NAME=mac;;
    CYGWIN*)    OS_NAME=windows;;
    MINGW*)     OS_NAME=windows;;
    *)          OS_NAME="UNKNOWN:${OS_INFORMATION}"
esac

if [ $OS_NAME == 'linux' ]; then
    sudo setfacl -dR -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./
    sudo setfacl -R -m u:$(whoami):rwX -m u:82:rwX -m u:100:rX ./
elif [ $OS_NAME == 'mac' ]; then
    sudo dseditgroup -o edit -a $(id -un) -t user $(id -gn 82)
fi

docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d

docker-compose -f docker-compose.yml -f docker-compose-dev.yml exec -u root php sh -c "chmod -R a+w /var/www/html/web/sites/default"
docker-compose -f docker-compose.yml -f docker-compose-dev.yml exec -u root php sh -c "chmod -R a+w /tmp/cache"

docker-compose exec php ./automation/bin/build.sh --mode dev

set +e
docker-compose exec -u $(id -u):$(id -g) php composer prepare-settings
set -e

docker-compose exec -u $(id -u):$(id -g) php ./automation/bin/install.sh
