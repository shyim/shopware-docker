#/bin/bash

case "$1" in
  build)
    docker-compose run -eANT_OPTS=-D"file.encoding=UTF-8" -u 1000 cli ant -Dapp.host=$2.localhost -Ddb.host=mysql -Ddb.user=root -Ddb.password=root -Ddb.name=$2 -f /var/www/html/$2/build/build.xml build-unit
    ;;
  drop)
	docker-compose run -eANT_OPTS=-D"file.encoding=UTF-8" -u 1000 cli mysql -h mysql -u root -proot -e "DROP DATABASE $2"
  	;;

  *)
    echo "Usage: $0 {build|drop}"
    ;;
esac
