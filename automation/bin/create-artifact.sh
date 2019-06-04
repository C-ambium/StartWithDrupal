#!/bin/bash
set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo "Loading common file"
source .common

cd ${PROJECT_DIR}

printf "{\"time\":\"%s\",\"hash\":\"%s\",\"tag\":\"%s\"}" `date -u +%Y-%m-%dT%H:%M:%SZ` ${CI_COMMIT_SHA} ${CI_COMMIT_REF_SLUG} > ./web/version.json
tar \
  --exclude-vcs \
  --exclude='automation/docker' \
  --exclude='automation/kubernetes' \
  --exclude='docker*.yml' \
  --exclude='docker*.yml.dist' \
  --exclude='Makefile' \
  --exclude='README.md' \
  -zcf ./artifact.tar.gz *