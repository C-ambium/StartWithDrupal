<?php

namespace Drupal\site_factory\Form;

use Drupal\Core\Entity\ContentEntityForm;
use Drupal\Core\Form\FormStateInterface;

/**
 * Form controller for Site edit forms.
 *
 * @ingroup site_factory
 */
class SiteForm extends ContentEntityForm {

  /**
   * {@inheritdoc}
   */
  public function save(array $form, FormStateInterface $form_state) {
    $entity = &$this->entity;

    $status = parent::save($form, $form_state);

    switch ($status) {
      case SAVED_NEW:
        drupal_set_message($this->t('Created the %label Site.', [
          '%label' => $entity->label(),
        ]));
        break;

      default:
        drupal_set_message($this->t('Saved the %label Site.', [
          '%label' => $entity->label(),
        ]));
    }
    $form_state->setRedirect('entity.site.canonical', ['site' => $entity->id()]);
  }

}
