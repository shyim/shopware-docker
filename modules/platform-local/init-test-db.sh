project=$2

compose exec mysql mysql -uroot -proot -e "DROP DATABASE IF EXISTS ${project}_test"
compose exec mysql mysql -uroot -proot -e "CREATE DATABASE ${project}_test"
compose exec mysql bash -c "mysqldump -uroot -proot ${project} | mysql -uroot -proot ${project}_test"