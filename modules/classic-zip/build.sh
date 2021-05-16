#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"

cd /var/www/html/"$SHOPWARE_PROJECT" || exit 1

rm recovery/install/data/install.lock || true

URL=$(get_url "$SHOPWARE_PROJECT")
HOST=$(echo "$URL" | sed s/'http[s]\?:\/\/'//)

php recovery/install/index.php \
  --no-interaction \
      --no-skip-import \
      --db-host="mysql" \
      --db-user="root" \
      --db-password="${MYSQL_ROOT_PASSWORD}" \
      --db-name="$SHOPWARE_PROJECT" \
      --shop-locale="de_DE" \
      --shop-host="${HOST}" \
      --shop-path="" \
      --shop-name="Shop" \
      --shop-email="test@example.com" \
      --shop-currency="EUR" \
      --admin-username="demo" \
      --admin-password="demo" \
      --admin-email="demo" \
      --admin-name="Demo" \
      --admin-locale="de_DE"

php bin/console sw:firstrunwizard:disable
php bin/console sw:cache:clear