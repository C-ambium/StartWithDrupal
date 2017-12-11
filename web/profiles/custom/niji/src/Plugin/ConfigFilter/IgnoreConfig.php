<?php

namespace Drupal\niji\plugin\ConfigFilter;

use Drupal\config_filter\Plugin\ConfigFilterBase;
use Drupal\Core\Extension\ModuleHandlerInterface;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Drupal\Core\Site\Settings;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Provides a filter to ignore some configuration.
 *
 * To ignore all configuration provided by one module, put this settings into
 * your settings.php file (for example) :
 *
 * $settings['config_export_blacklist_module'] = ['devel', 'webprofiler'];
 *
 * To ignore all designated configuration, put this settings into your
 * settings.php file (for example) :
 *
 * $settings['config_export_blacklist_config'] = ['webprofiler.config'];
 *
 * @ConfigFilter(
 *   id = "ignore_config",
 *   label = "Ignore Config",
 *   weight = 10
 * )
 */
class IgnoreConfig extends ConfigFilterBase implements ContainerFactoryPluginInterface {

  /**
   * The module handler.
   *
   * @var \Drupal\Core\Extension\ModuleHandlerInterface
   */
  protected $moduleHandler;

  /**
   * List of all modules to ignore.
   *
   * @var array
   */
  protected $ignoredModules;

  /**
   * List of all configuration names to ignore.
   *
   * @var array
   */
  protected $ignoredConfig = [];

  /**
   * {@inheritdoc}
   */
  public function __construct(array $configuration, $plugin_id, $plugin_definition, ModuleHandlerInterface $module_handler) {
    parent::__construct($configuration, $plugin_id, $plugin_definition);

    $this->moduleHandler = $module_handler;
    $ignored_modules = Settings::get('config_export_blacklist_module');
    $this->ignoredModules = $ignored_modules;
    $this->ignoredConfig = (Settings::get('config_export_blacklist_config')) ?: [];
    $this->generateIgnoredConfigurations();
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition) {
    return new static(
      $configuration,
      $plugin_id,
      $plugin_definition,
      $container->get('module_handler')
    );
  }

  /**
   * Generate a list with configurations to be ignored.
   */
  protected function generateIgnoredConfigurations() {
    if (!empty($this->ignoredModules)) {
      $ignored_conf_provided_by_modules = [];
      foreach ($this->ignoredModules as $module) {
        if ($this->moduleHandler->moduleExists($module)) {
          $file_name_pattern = DRUPAL_ROOT . '/' . $this->moduleHandler->getModule($module)->getPath() . '/config/install/*.yml';
          $ignored_conf_provided_by_modules = array_merge($ignored_conf_provided_by_modules, glob($file_name_pattern));
        }
      }

      array_walk($ignored_conf_provided_by_modules, function (&$value) {
        $value = basename($value, '.yml');
      });

      $this->ignoredConfig = array_merge($this->ignoredConfig, $ignored_conf_provided_by_modules);
    }

    $this->ignoredConfig = array_unique($this->ignoredConfig);
  }

  /**
   * Check if a config must be ignored.
   *
   * @param string $config_name
   *   The config name.
   *
   * @return bool
   *   no description
   */
  protected function ignoreMatchName($config_name) {
    return in_array($config_name, $this->ignoredConfig);
  }

  /**
   * {@inheritdoc}
   */
  public function filterWrite($name, array $data) {
    if ($this->ignoreMatchName($name)) {
      return NULL;
    }

    // Remove additional module in core.extension.
    if ($name == 'core.extension') {
      foreach ($this->ignoredModules as $module) {
        unset($data['module'][$module]);
      }
    }

    return $data;
  }

  /**
   * {@inheritdoc}
   */
  public function filterCreateCollection($collection) {
    return $this;
  }

}
