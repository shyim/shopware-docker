# shopware-docker

## Why i build it, there are already docker images for shopware?

I have a little bit another use case, i need different php versions for testing. Also i hate apache so i use as webserver everywhere nginx with php-fpm.
Also all images does not contain ioncube, because i dont need it while developing in the core.
Every folder in `~/Code` is a subdomain which makes testing very helpful. ("~/Code/shopware" => http://shopware.localhost)
And at last every thing is designed to use of shopware git version.

## How to setup?

* Clone the repository somewhere
* Optional: Do a symlink from swdc to `/usr/local/bin/swdc`
* `swdc up`: Starts the docker-compose
* Checkout in `~/Code/shopware` the offical shopware repository or your shopware composer project ([read this](#what-do-i-need-to-prepare-to-use-shopware-composer-projects))
* Execute `swdc build shopware`

## Which commands exist?

* `swdc up` - Starts the containers
* `swdc down` - Stops the containers
* `swdc build [Folder name in ~/Code]` - Runs build unit, cleares cache, sets developer config (throwExceptions)
* `swdc test [Folder name in ~/Code]` - Runs unit tests for it
* `swdc snippets [Folder name in ~/Code]` - Imports all new snippets for that shop
* `swdc snap [Folder name in ~/Code] [Name]` - Creates a database snapshot
* `swdc rsnap [Folder name in ~/Code] [Name]` - Restores a database snapshot
* `swdc apply [Folder name in ~/Code] [Name]` - Apply a fixture
* `swdc shell` - Opens the a bash shell in cli container
* `swdc version [PHP Version] [MySQL Version]` - Generate a docker-compose.override.yaml to choose a another version
* `swdc update-test` - Runs migration in update mode


## Which configs pre-sets are exists?

All configs can be applied with `swdc config [Folder name in ~/Code] [Name]`

* bi - Sets bi endpoint to staging
* sbp - Sets store endpoint to staging
* template - Enables forceCompile
* elastic - Enables elasticsearch

## Which fixtures are available?

All fixtures can be applied with `swdc apply [Folder name in ~/Code] [Name]`

* api - Sets a apiKey for the demo user with "demo"
* bi-reset - Resets all bi statistics

## Which images and tags are available?

* [shopware/shopware-nginx](https://hub.docker.com/r/shyim/shopware-nginx/tags)
* [shopware/shopware-mysql](https://hub.docker.com/r/shyim/shopware-mysql/tags)
* [shopware/shopware-cli](https://hub.docker.com/r/shyim/shopware-cli/tags)

## What do I need to prepare to use shopware composer projects?

The databases are stored temporarily by default. Change the following in your docker-compose.yml to keep your database on restart:

```yml
  mysql:
    image: shyim/shopware-mysql:57
    env_file: .env
    ports:
      - 3306:3306
    tmpfs:
      - /var/lib/mysql
    restart: always
```

```yml
  mysql:
    image: shyim/shopware-mysql:5.7
    env_file: .env
    ports:
      - 3306:3306
```

## Can i use it on Windows / Mac?

I dont't develop on Windows or Mac. Try it out by own