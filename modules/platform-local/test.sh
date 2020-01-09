project=$2

docker-compose -f ${DOCKER_COMPOSE_FILE} exec mysql mysql -uroot -proot -e "DROP DATABASE IF EXISTS ${project}_test"
docker-compose -f ${DOCKER_COMPOSE_FILE} exec mysql mysql -uroot -proot -e "CREATE DATABASE ${project}_test"
docker-compose -f ${DOCKER_COMPOSE_FILE} exec mysql bash -c "mysqldump -uroot -proot ${project} | mysql -uroot -proot ${project}_test"

compose exec cli bash /opt/swdc/swdc-inside test $2 ${@:3}