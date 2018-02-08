#!/usr/bin/env sh

cd "$( dirname "$0" )"

echo "Loading common file"
. ./.common

${PHPCS} --config-set ignore_warnings_on_exit 1

${PHPCS} \
--standard=Drupal,DrupalPractice \
--extensions=php,module,inc,install,test,profile,theme,css,info,txt,md \
--ignore="*/node_modules/*,*/themes/*/css/*" \
${APP_DIR}/profiles/custom ${APP_DIR}/modules/custom ${APP_DIR}/themes/custom
