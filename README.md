# shopware-docker

This setup works for Shopware 5, Shopware 5 Composer Project and 6 (Development Template)

## How to setup?

* Clone the repository somewhere
* Optional: Do a symlink from swdc to `/usr/local/bin/swdc`
* Copy `.env.dist` to `$HOME/.config/swdc/env` or just run `swdc`
* `swdc up`: Starts the docker-compose with the containers

## Creating projects

* Create a new folder in `~/Code/` with your project name and checkout a shopware installation
* Run `swdc build [Folder Name]`
* After the installation succeed, can you open the shop with the command `swdc open [Folder Name]`

### Custom code directory

* You may change the code directory which the shopware installations lie in by
  modifying the `CODE_DIRECTORY` variable in `$HOME/.config/swdc/env`

## Custom options per directory

* You can override the image, hosts and the used ssl certificate

* VHOST_**FOLDER_NAME**_IMAGE
  * Allows changing the image that is used for this directory.
  * Files are mount to /var/www/html, the image should expose a webservice at port 80
* VHOST_**FOLDER_NAME**_HOSTS
  * This can be an list of hosts comma seperated. The first host will be used for the Installation
* VHOST_**FOLDER_NAME**_CERT_NAME
  * This can be used to define another ssl certificate for this vhost.
  * Example: `shop`. You will need following files  `~/.config/swdc/ssl/shop.crt` and `~/.config/swdc/ssl/shop.key`

## Which commands exist?

### Module: base

* `swdc command-list`              
* `swdc debug-logs`                Please use this command to collect informations for a Github Issue
* `swdc debug`                     Symfony Var-dump Server, use swdump() in your Code
* `swdc down`                      Stops the containers
* `swdc generate-command-list`     Generates the command list for README.md
* `swdc help`                      
* `swdc log`                       Shows the log of the specified container
* `swdc mysql`                     Starts the mysql client on the cli container
* `swdc open`                      Opens the given shop in browser
* `swdc shell-root`                Joins into the cli container as root user
* `swdc shell`                     Joins into the cli container as normal user
* `swdc update-images`             Updates used docker images
* `swdc up`                        Starts the containers
* `swdc up xdebug`                 Starts the containers with xdebug enabled

### Module: classic

* `swdc apply`                     Applys a database fixture
* `swdc build`                     Reinstalls the database
* `swdc config`                    Applies fixture to the config.php
* `swdc download-testimages`       Download and extract shopware testimages
* `swdc hooks`                     Fixes the hooks for git
* `swdc mink`                      Run mink tests
* `swdc snippets`                  Reimports all snippets
* `swdc test`                      Runs all tests
* `swdc unit`                      Runs only unit tests
* `swdc update-test`               Simulate a update

### Module: classic-composer

* `swdc build`                     Reinstalls the database         

### Module: docker

* `swdc drop`                      Drops the database
* `swdc es-clear`                  Deletes everything from elasticsearch server
* `swdc rsnap`                     Loads back a created snapshot
* `swdc snap`                      Creates a new snapshot

### Module: local

* `swdc configure`                 Opens the configuration .env file with your favourite editor

### Module: platform

* `swdc admin-build`               Builds the administration and executes assets install
* `swdc admin-watch`               Start the admin watcher at port 8181
* `swdc build`                     Reinstalls the database
  * available parameter
    * `--without-demo-data`          Don't generate demo-data
    * `--without-building`           Don't build the storefront and administration
* `swdc storefront-build`          Builds the storefront
* `swdc storefront-watch`          Recompile the storefront when changes in its resources are detected
* `swdc unit`                      Runs all unit tests

## Which images and tags are available?

* [shopware/shopware-classic-nginx](https://hub.docker.com/r/shyim/shopware-classic-nginx/tags)
* [shopware/shopware-platform-nginx](https://hub.docker.com/r/shyim/shopware-platform-nginx/tags)
* [shopware/shopware-classic-apache](https://hub.docker.com/r/shyim/shopware-classic-apache/tags)
* [shopware/shopware-platform-apache](https://hub.docker.com/r/shyim/shopware-platform-apache/tags)
* [shopware/shopware-mysql](https://hub.docker.com/r/shyim/shopware-mysql/tags)
* [shopware/shopware-cli](https://hub.docker.com/r/shyim/shopware-cli/tags)

## How can i access the shop?

* You can use http://**FOLDERNAME**.dev.localhost
* Or use `swdc open [Folder Name]`

## Can i use it on Windows / Mac?

I dont't develop on Windows or Mac. Try it out by own

## What are the passwords?

### SMTP

MailDev: http://mail.localhost  
Host: smtp  
Port: 25  
no Login  
no Encryption  
no authetification

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

### Shopware 6

User: admin  
Password: shopware

### Minio (S3)

Host: minio  
Key: AKIAIOSFODNN7EXAMPLE  
Secret-Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY  
Bucket can be created on page http://localhost:9000/minio/
