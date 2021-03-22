#!/usr/bin/env bash

mysql -h mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$SHOPWARE_PROJECT" -e "DELETE FROM enqueue"
mysql -h mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$SHOPWARE_PROJECT" -e "DELETE FROM message_queue_stats"
mysql -h mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$SHOPWARE_PROJECT" -e "DELETE FROM dead_message"
mysql -h mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$SHOPWARE_PROJECT" -e "DELETE FROM message_queue_stats"
mysql -h mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$SHOPWARE_PROJECT" -e "DELETE FROM elasticsearch_index_task"