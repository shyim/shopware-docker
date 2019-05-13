# shopware-docker

This setup works for Shopware 5, Shopware 5 Composer Project and Platform

## How to setup?

* Clone the repository somewhere
* Optional: Do a symlink from swdc to `/usr/local/bin/swdc`
* Configure your needs in ".env" file
* `swdc up`: Starts the docker-compose with the containers

## Creating projects

* Create a new folder in ~/Code/ with your project name and checkout a shopware installation
* Run `swdc build [Folder Name]`
* After the installation succeed, can you open the shop with the command `swdc open [Folder Name]`

### Custom code directory

* You may change the code directory which the shopware installations lie in by
  modifying the `CODE_DIRECTORY` variable in `.env`

## Which commands exist?

### Module: base

* `swdc debug-logs`                Please use this command to collect informations for a Github Issue
* `swdc down`                      Stops the containers
* `swdc generate-command-list`     Generates the command list for README.md
* `swdc help`                      
* `swdc open`                      Opens the given shop in browser
* `swdc shell-root`                Joins into the cli container as root user
* `swdc shell`                     Joins into the cli container as normal user
* `swdc update-images`             Updates used docker images
* `swdc up`                        Starts the containers

### Module: classic

* `swdc apply`                     Applys a database fixture
* `swdc build`                     Reinstalls the database
* `swdc config`                    Applies fixture to the config.php
* `swdc hooks`                     Fixes the hooks for git
* `swdc snippets`                  Reimports all snippets
* `swdc test`                      Runs all tests
* `swdc update-test`               Simulate a update

### Module: classic-composer

* `swdc build`                     Reinstalls the database

### Module: docker

* `swdc drop`                      Drops the database
* `swdc rsnap`                     Loads back a created snapshot
* `swdc snap`                      Creates a new snapshot

### Module: platform

* `swdc admin-watch`               Start the admin watcher at port 8181
* `swdc build`                     Reinstalls the database
* `swdc unit`                      Runs all unit tests

## Which images and tags are available?

* [shopware/shopware-nginx](https://hub.docker.com/r/shyim/shopware-nginx/tags)
* [shopware/shopware-mysql](https://hub.docker.com/r/shyim/shopware-mysql/tags)
* [shopware/shopware-cli](https://hub.docker.com/r/shyim/shopware-cli/tags)

## How can i access the shop?

* For Shopware 5 you can use http://**FOLDERNAME**.dev.localhost
* For Shopware Platform you can use http://**FOLDERNAME**.platform.localhost
* Or use `swdc open [Folder Name]`

## Can i use it on Windows / Mac?

I dont't develop on Windows or Mac. Try it out by own

## What are the passwords?

### SMTP

Mailhog: http://mail.localhost

### MySQL

Host: mysql
User: root
Password: root
PhpMyAdmin / Adminer: http://db.localhost

## ElasticSearch

Access es directly: http://es.localhost
Access cerebro: http://cerebro.localhost

### Shopware

User: demo

Password: demo

### Minio (S3)

Host: minio

Key: AKIAIOSFODNN7EXAMPLE

Secret-Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Bucket can be created on page http://localhost:9000/minio/
