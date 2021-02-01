cd "/var/www/html/${SHOPWARE_PROJECT}" || exit

while true; do
  php bin/console messenger:consume --memory-limit=1G -vv
done
