


```bash
docker build -t niji-socle-drupal-php \
    --build-arg FROM_IMAGE=wodby/drupal-php:7.1-3.0.0 \
    --build-arg ARTIFACTORY_ACCESS_TOKEN=${ARTIFACTORY_ACCESS_TOKEN} \
    --build-arg ARTIFACT_URI=https://artifactory.niji.delivery/artifactory/niji-socle-drupal-local/master.tar.gz \
    --quiet \
    .
```

```bash
docker build -t niji-socle-drupal-apache \
    --build-arg FROM_IMAGE=wodby/php-apache:2.4-2.0.0 \
    --build-arg ARTIFACTORY_ACCESS_TOKEN=${ARTIFACTORY_ACCESS_TOKEN} \
    --build-arg ARTIFACT_URI=https://artifactory.niji.delivery/artifactory/niji-socle-drupal-local/master.tar.gz \
    --quiet \
    .
```
