<?php

namespace DrupalApp\composer;

use Drupal\Component\Utility\Crypt;
use Symfony\Component\Yaml\Yaml;
use Composer\Script\Event;

/**
 * Class Settings
 */
class Settings {

  /**
   * Prepare the settings.local.php file
   *
   * @param \Composer\Script\Event $event
   *   The composer event.
   */
  public static function prepare(Event $event) {
    $twig_loader = new \Twig_Loader_Filesystem(getcwd() . '/settings/templates/');
    $twig_environment = new \Twig_Environment($twig_loader);
    $target_settings_directory = getcwd() . '/web/sites/default/';
    $target_settings_file = $target_settings_directory . 'settings.local.php';

    $replacement = [];
    foreach (self::getParameters($event) as $setting_key => $setting_value) {
      $replacement[$setting_key] = $setting_value;

      // Special case for array parameter.
      if (is_array($setting_value)) {
        $replacement[$setting_key] = "[\n";
        foreach ($setting_value as $value) {
          $replacement[$setting_key] .= "  '" . $value . "',\n";
        }
        $replacement[$setting_key] .= "]";
      }
    }

    $replacement['hash_salt'] = Crypt::randomBytesBase64(55);

    $new_settings = $twig_environment->render('settings.local.php.twig', $replacement);
    chmod($target_settings_directory, 0755);
    if (file_exists($target_settings_file)) {
      chmod($target_settings_file, 0644);
    }
    file_put_contents($target_settings_file, $new_settings);
  }

  /**
   * Get parameters.
   *
   * @param \Composer\Script\Event $event
   *   The composer event.
   *
   * @return mixed
   *   The YAML converted to a PHP value
   */
  protected static function getParameters(Event $event) {
    $parameter_file = getcwd() . '/settings/parameters.yml';
    $parameter_dist_file = getcwd() . '/settings/parameters.dist.yml';

    $event->getIO()->write("<info>Generate settings file:</info>");

    if (file_exists($parameter_file)) {
      $event->getIO()->write("Create settings.local.php from the settings/parameters.yml file");
      return Yaml::parse(file_get_contents($parameter_file));
    }

    $event->getIO()->write("Create settings.local.php from the settings/parameters.dist.yml file");
    $event->getIO()->write("To overwrite settings, please create the settings/parameters.yml from the settings/parameters.dist.yml file");

    return Yaml::parse(file_get_contents($parameter_dist_file));
  }

}
