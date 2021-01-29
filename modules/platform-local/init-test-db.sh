project=$2

echo "DROP DATABASE IF EXISTS ${project}_test" | compose exec -T mysql mysql -uroot -proot 
echo "CREATE DATABASE ${project}_test" | compose exec -T mysql mysql -uroot -proot
compose exec -T mysql mysqldump -uroot -proot ${project} | compose exec -T mysql mysql -uroot -proot "${project}_test"