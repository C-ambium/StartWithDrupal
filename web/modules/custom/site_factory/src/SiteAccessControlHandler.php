<?php

namespace Drupal\site_factory;

use Drupal\Core\Entity\EntityAccessControlHandler;
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Session\AccountInterface;
use Drupal\Core\Access\AccessResult;

/**
 * Access controller for the Site entity.
 *
 * @see \Drupal\site_factory\Entity\Site.
 */
class SiteAccessControlHandler extends EntityAccessControlHandler {

  /**
   * {@inheritdoc}
   */
  protected function checkAccess(EntityInterface $entity, $operation, AccountInterface $account) {
    /** @var \Drupal\site_factory\Entity\SiteInterface $entity */
    switch ($operation) {
      case 'view':
        if (!$entity->isPublished()) {
          return AccessResult::allowedIfHasPermission($account, 'view unpublished site entities');
        }
        return AccessResult::allowedIfHasPermission($account, 'view published site entities');

      case 'update':
        return AccessResult::allowedIfHasPermission($account, 'edit site entities');

      case 'delete':
        return AccessResult::allowedIfHasPermission($account, 'delete site entities');
    }

    // Unknown operation, no opinion.
    return AccessResult::neutral();
  }

  /**
   * {@inheritdoc}
   */
  protected function checkCreateAccess(AccountInterface $account, array $context, $entity_bundle = NULL) {
    return AccessResult::allowedIfHasPermission($account, 'add site entities');
  }

}
