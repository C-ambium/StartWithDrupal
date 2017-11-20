# Application Drupal

Ce socle applicatif est totalement découplée de tout hébergement.
Il peut être utilisé dans un environnement LAMP, tout comme dans un environnement docker par exemple.

## Paramètres

Par défaut le fichier `parameters.dist.yml` est utilisé.

Pour définir ses propres paramètres, copier le fichier `parameters.dist.yml` en `parameters.yml` et modifier les paramètres

Les paramètres par défaut sont :

```yaml
additional_modules: &additional_modules
  - 'devel'
  - 'kint'
  - 'vardumper'
  - 'vardumper_console'
  - 'webprofiler'
cache_maxage: '31536000'
config_export_blacklist_module: *additional_modules
config_export_blacklist_config: 'null'
css_preprocess: 'TRUE'
db_host: 'mariadb'
db_name: 'drupal'
db_pass: 'drupal'
db_user: 'drupal'
error_level: 'verbose'
js_preprocess: 'TRUE'
redis_host: 'redis'
site_name: 'drupal'
```

## Installation / Mise à jour

### Build

`./automation/bin/build.sh`

Ajouter la paramètre `--mode dev` pour une inclure les dépendances de développement.

### Installation

`./automation/bin/install.sh`

Attention, la base de donnée est supprimée lors de chaque installation.

### Mise à jour

`./automation/bin/update.sh`

## Divers

### Reconstruire les paramètres

`composer prepare-settings`

### Code sniffer

`./automation/bin/code_sniffer.sh`

### Reset password

`./automation/bin/reset_password.sh`
