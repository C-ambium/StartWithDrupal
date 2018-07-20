#!/usr/bin/env bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

source .common

echo_info "Install DRUPAL"

cd ${APP_DIR}

${DRUSH} site:install starter_kit \
  -y install_configure_form.update_status_module='array(FALSE,FALSE)' || error

# Re-init drupal console.
${DRUPAL} init --no-interaction --override --quiet || error

# Enforce cache rebuild.
${DRUSH} cr

chmod +w ${APP_DIR}/sites/default
chmod +w ${APP_DIR}/sites/default/*

echo_info "Install DRUPAL Finished"
