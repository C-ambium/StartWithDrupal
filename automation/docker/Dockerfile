ARG FROM_IMAGE
FROM ${FROM_IMAGE}

ARG ARTIFACTORY_ACCESS_TOKEN
ARG ARTIFACT_URI

USER root

RUN \
  cd /var/www/html && \
  curl -H"Authorization: Bearer ${ARTIFACTORY_ACCESS_TOKEN}" -k ${ARTIFACT_URI} | tar xzv && \
  chown -R 82:82 /var/www/html

USER 82
