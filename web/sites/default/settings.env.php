<?php

# Settings.
//$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
//$settings['cache']['default'] = 'cache.backend.null';
$settings['extension_discovery_scan_tests'] = TRUE;
$settings['file_chmod_directory'] = 0775;
$settings['file_chmod_file'] = 0664;
$settings['hash_salt'] = 'e-CQHqybWcnrbIQ_p1ZmsdMz32Xf7wiJJUJw-NXpwK5Rgcs5KvsOoN90hASE-iotVub33l_nWQ';

# Redis cache
if (constant("MAINTENANCE_MODE") != 'install') {
  $settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/redis.services.yml';

  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = getenv('REDIS_HOST');
  $settings['cache_prefix'] = '_';
  $settings['cache']['default'] = 'cache.backend.redis';

  $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';
}

// Additional module to enable during installation.
$settings['additional_modules'] = [
  'devel',
  'kint',
  'vardumper',
  'vardumper_console',
  'webprofiler',
];

// Custom settings to ignore some configuration
// provided by modules on export.
$settings['config_export_blacklist_module'] = [
  'devel',
  'kint',
  'vardumper',
  'vardumper_console',
  'webprofiler',
];

// Custom settings to ignore some configuration on export.
$settings['config_export_blacklist_config'] = null;

# Databases.
$databases['default']['default'] = array(
    'driver' => 'mysql',
    'database' => getenv('DB_NAME'),
    'username' => getenv('DB_USER'),
    'password' => getenv('DB_PASSWORD'),
    'host' => getenv('DB_HOST'),
    'port' => 3306,
    'prefix' => '',
    'collation' => 'utf8mb4_general_ci',
    'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
);

# Override config entities.
$config['system.logging']['error_level'] = 'verbose';
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;
$config['system.performance']['cache.page.max_age'] = 31536000;

$settings['trusted_host_patterns'] = [
  '^.*$',
];

# Config directories
$config_directories = array(
    CONFIG_SYNC_DIRECTORY => getcwd() . '/../config/'
);
