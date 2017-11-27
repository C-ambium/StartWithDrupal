
docker-compose -f docker-compose.yml -f docker-compose-dev-win.yml up -d

docker-compose exec php ./automation/bin/build.sh --mode dev

docker-compose exec php composer prepare-settings

docker-compose exec php ./automation/bin/install.sh
