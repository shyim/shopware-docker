cd "/var/www/html/${SHOPWARE_PROJECT}"

php dev-ops/analyze/vendor/bin/ecs check --fix vendor/shopware/platform/src --config vendor/shopware/platform/easy-coding-standard.yml

php dev-ops/analyze/phpstan-config-generator.php
php dev-ops/analyze/vendor/bin/phpstan analyze --configuration vendor/shopware/platform/phpstan.neon
php dev-ops/analyze/vendor/bin/psalm --config=vendor/shopware/platform/psalm.xml --threads=4 --show-info=false