
for D in `find /var/www/html -maxdepth 1 -mindepth 1 -type d`
do
    if [[ -f "${D}/public/index.php" ]]; then
        chown dev:dev "${D}/var/cache" -R
        chmod +x "${D}/var/cache" -R
    else
        chown dev:dev "${D}/var/cache" -R
        chmod +x "${D}/var/cache" -R
        chown dev:dev "${D}/web/cache" -R
        chmod +x "${D}/web/cache" -R
    fi
done
