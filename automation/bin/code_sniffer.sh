#!/usr/bin/env bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo "Loading common file"
source .common

${PHPCS} --config-set installed_paths ${APP_DIR}/modules/contrib/coder/coder_sniffer/

${PHPCS} \
--standard=Drupal,DrupalPractice \
--extensions=php,module,inc,install,test,profile,theme,css,info,txt,md \
--ignore="*/node_modules/*,*/themes/*/css/*" \
${APP_DIR}/profiles/custom ${APP_DIR}/modules/custom ${APP_DIR}/themes/custom
