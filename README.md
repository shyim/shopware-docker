# shopware-docker

## Why i build it, there are already docker images for shopware?

I have a little bit another use case, i need different php versions for testing. Also i hate apache so i use as webserver everywhere nginx with php-fpm.
Also all images does not contain ioncube, because i dont need it while developing in the core.
Every folder in `~/Code` is a subdomain which makes testing very helpful. ("~/Code/shopware" => http://shopware.localhost)
And at last every thing is designed to use of shopware git version.

## How to setup?

Mac or Windows users should use the `docker-compose-win.yml` which adds volumens and uses sftp.

* Clone the repository somewhere
* Optional: Do a symlink from swdc to `/usr/local/bin/swdc`
* `swdc up`: Starts the docker-compose
* Checkout in `~/Code/shopware` the offical shopware repository
* Execute `swdc build shopware`

## Which commands exist?

* `swdc up` - Starts the containers
* `swdc down` - Stops the containers
* `swdc build [Folder name in ~/Code]` - Runs build unit, cleares cache, sets developer config (throwExceptions)
* `swdc build [Folder name in ~/Code] template` - Runs build unit, cleares cache, sets developer config (throwExceptions) and *sets forceCompile*
* `swdc build [Folder name in ~/Code] elastic` - Runs build unit, cleares cache, sets developer config (throwExceptions) and *enables ElasticSearch*
* `swdc shell` - Opens the a bash shell in cli container
* `swdc config [Folder name in ~/Code] template` - Adds forceCompile
* `swdc config [Folder name in ~/Code] elastic` - Activates elasticsearch
