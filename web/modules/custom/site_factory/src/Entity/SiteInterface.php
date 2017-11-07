<?php

namespace Drupal\site_factory\Entity;

use Drupal\Core\Entity\ContentEntityInterface;
use Drupal\Core\Entity\EntityChangedInterface;
use Drupal\user\EntityOwnerInterface;

/**
 * Provides an interface for defining Site entities.
 *
 * @ingroup site_factory
 */
interface SiteInterface extends  ContentEntityInterface, EntityChangedInterface, EntityOwnerInterface {

  // Add get/set methods for your configuration properties here.

  /**
   * Gets the Site name.
   *
   * @return string
   *   Name of the Site.
   */
  public function getName();

  /**
   * Sets the Site name.
   *
   * @param string $name
   *   The Site name.
   *
   * @return \Drupal\site_factory\Entity\SiteInterface
   *   The called Site entity.
   */
  public function setName($name);

  /**
   * Gets the Site creation timestamp.
   *
   * @return int
   *   Creation timestamp of the Site.
   */
  public function getCreatedTime();

  /**
   * Sets the Site creation timestamp.
   *
   * @param int $timestamp
   *   The Site creation timestamp.
   *
   * @return \Drupal\site_factory\Entity\SiteInterface
   *   The called Site entity.
   */
  public function setCreatedTime($timestamp);

  /**
   * Returns the Site published status indicator.
   *
   * Unpublished Site are only visible to restricted users.
   *
   * @return bool
   *   TRUE if the Site is published.
   */
  public function isPublished();

  /**
   * Sets the published status of a Site.
   *
   * @param bool $published
   *   TRUE to set this Site to published, FALSE to set it to unpublished.
   *
   * @return \Drupal\site_factory\Entity\SiteInterface
   *   The called Site entity.
   */
  public function setPublished($published);

}
