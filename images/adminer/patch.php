<?php

file_put_contents('/var/www/html/adminer.php', str_replace('"HEX(".idf_escape($o["field"]).")"', '"LOWER(HEX(".idf_escape($o["field"])."))"', file_get_contents('/var/www/html/adminer.php')));
