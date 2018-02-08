#!/usr/bin/env sh

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
PROJECT_DIR=${DIR}/../..
APP_DIR=${PROJECT_DIR}/web

${PHPCS} --config-set ignore_warnings_on_exit 1

${PHPCS} \
--standard=Drupal,DrupalPractice \
--extensions=php,module,inc,install,test,profile,theme,css,info,txt,md \
--ignore="*/node_modules/*,*/themes/*/css/*" \
${APP_DIR}/profiles/custom ${APP_DIR}/modules/custom ${APP_DIR}/themes/custom
