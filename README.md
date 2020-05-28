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
* **FOLDER_NAME** has to be in uppercase. Example for image: Folder name is: **sw5**, VHOST_**SW5**_IMAGE

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

## Sponsors

[<img src="https://sponsor.shyim.de/image/0?1" width="35">](https://sponsor.shyim.de/profile/0)
[<img src="https://sponsor.shyim.de/image/1?1" width="35">](https://sponsor.shyim.de/profile/1)
[<img src="https://sponsor.shyim.de/image/2?1" width="35">](https://sponsor.shyim.de/profile/2)
[<img src="https://sponsor.shyim.de/image/3?1" width="35">](https://sponsor.shyim.de/profile/3)
[<img src="https://sponsor.shyim.de/image/4?1" width="35">](https://sponsor.shyim.de/profile/4)
[<img src="https://sponsor.shyim.de/image/5?1" width="35">](https://sponsor.shyim.de/profile/5)
[<img src="https://sponsor.shyim.de/image/6?1" width="35">](https://sponsor.shyim.de/profile/6)
[<img src="https://sponsor.shyim.de/image/7?1" width="35">](https://sponsor.shyim.de/profile/7)
[<img src="https://sponsor.shyim.de/image/8?1" width="35">](https://sponsor.shyim.de/profile/8)
[<img src="https://sponsor.shyim.de/image/9?1" width="35">](https://sponsor.shyim.de/profile/9)
[<img src="https://sponsor.shyim.de/image/10?1" width="35">](https://sponsor.shyim.de/profile/10)
[<img src="https://sponsor.shyim.de/image/11?1" width="35">](https://sponsor.shyim.de/profile/11)
[<img src="https://sponsor.shyim.de/image/12?1" width="35">](https://sponsor.shyim.de/profile/12)
[<img src="https://sponsor.shyim.de/image/13?1" width="35">](https://sponsor.shyim.de/profile/13)
[<img src="https://sponsor.shyim.de/image/14?1" width="35">](https://sponsor.shyim.de/profile/14)
[<img src="https://sponsor.shyim.de/image/15?1" width="35">](https://sponsor.shyim.de/profile/15)
[<img src="https://sponsor.shyim.de/image/16?1" width="35">](https://sponsor.shyim.de/profile/16)
[<img src="https://sponsor.shyim.de/image/17?1" width="35">](https://sponsor.shyim.de/profile/17)
[<img src="https://sponsor.shyim.de/image/18?1" width="35">](https://sponsor.shyim.de/profile/18)
[<img src="https://sponsor.shyim.de/image/19?1" width="35">](https://sponsor.shyim.de/profile/19)
[<img src="https://sponsor.shyim.de/image/20?1" width="35">](https://sponsor.shyim.de/profile/20)
[<img src="https://sponsor.shyim.de/image/21?1" width="35">](https://sponsor.shyim.de/profile/21)
[<img src="https://sponsor.shyim.de/image/22?1" width="35">](https://sponsor.shyim.de/profile/22)
[<img src="https://sponsor.shyim.de/image/23?1" width="35">](https://sponsor.shyim.de/profile/23)
[<img src="https://sponsor.shyim.de/image/24?1" width="35">](https://sponsor.shyim.de/profile/24)
[<img src="https://sponsor.shyim.de/image/25?1" width="35">](https://sponsor.shyim.de/profile/25)
[<img src="https://sponsor.shyim.de/image/26?1" width="35">](https://sponsor.shyim.de/profile/26)
[<img src="https://sponsor.shyim.de/image/27?1" width="35">](https://sponsor.shyim.de/profile/27)
[<img src="https://sponsor.shyim.de/image/28?1" width="35">](https://sponsor.shyim.de/profile/28)
[<img src="https://sponsor.shyim.de/image/29?1" width="35">](https://sponsor.shyim.de/profile/29)
[<img src="https://sponsor.shyim.de/image/30?1" width="35">](https://sponsor.shyim.de/profile/30)
[<img src="https://sponsor.shyim.de/image/31?1" width="35">](https://sponsor.shyim.de/profile/31)
[<img src="https://sponsor.shyim.de/image/32?1" width="35">](https://sponsor.shyim.de/profile/32)
[<img src="https://sponsor.shyim.de/image/33?1" width="35">](https://sponsor.shyim.de/profile/33)
[<img src="https://sponsor.shyim.de/image/34?1" width="35">](https://sponsor.shyim.de/profile/34)
[<img src="https://sponsor.shyim.de/image/35?1" width="35">](https://sponsor.shyim.de/profile/35)
[<img src="https://sponsor.shyim.de/image/36?1" width="35">](https://sponsor.shyim.de/profile/36)
[<img src="https://sponsor.shyim.de/image/37?1" width="35">](https://sponsor.shyim.de/profile/37)
[<img src="https://sponsor.shyim.de/image/38?1" width="35">](https://sponsor.shyim.de/profile/38)
[<img src="https://sponsor.shyim.de/image/39?1" width="35">](https://sponsor.shyim.de/profile/39)
[<img src="https://sponsor.shyim.de/image/40?1" width="35">](https://sponsor.shyim.de/profile/40)
[<img src="https://sponsor.shyim.de/image/41?1" width="35">](https://sponsor.shyim.de/profile/41)
[<img src="https://sponsor.shyim.de/image/42?1" width="35">](https://sponsor.shyim.de/profile/42)
[<img src="https://sponsor.shyim.de/image/43?1" width="35">](https://sponsor.shyim.de/profile/43)
[<img src="https://sponsor.shyim.de/image/44?1" width="35">](https://sponsor.shyim.de/profile/44)
[<img src="https://sponsor.shyim.de/image/45?1" width="35">](https://sponsor.shyim.de/profile/45)
[<img src="https://sponsor.shyim.de/image/46?1" width="35">](https://sponsor.shyim.de/profile/46)
[<img src="https://sponsor.shyim.de/image/47?1" width="35">](https://sponsor.shyim.de/profile/47)
[<img src="https://sponsor.shyim.de/image/48?1" width="35">](https://sponsor.shyim.de/profile/48)
[<img src="https://sponsor.shyim.de/image/49?1" width="35">](https://sponsor.shyim.de/profile/49)
[<img src="https://sponsor.shyim.de/image/50?1" width="35">](https://sponsor.shyim.de/profile/50)
[<img src="https://sponsor.shyim.de/image/51?1" width="35">](https://sponsor.shyim.de/profile/51)
[<img src="https://sponsor.shyim.de/image/52?1" width="35">](https://sponsor.shyim.de/profile/52)
[<img src="https://sponsor.shyim.de/image/53?1" width="35">](https://sponsor.shyim.de/profile/53)
[<img src="https://sponsor.shyim.de/image/54?1" width="35">](https://sponsor.shyim.de/profile/54)
[<img src="https://sponsor.shyim.de/image/55?1" width="35">](https://sponsor.shyim.de/profile/55)
[<img src="https://sponsor.shyim.de/image/56?1" width="35">](https://sponsor.shyim.de/profile/56)
[<img src="https://sponsor.shyim.de/image/57?1" width="35">](https://sponsor.shyim.de/profile/57)
[<img src="https://sponsor.shyim.de/image/58?1" width="35">](https://sponsor.shyim.de/profile/58)
[<img src="https://sponsor.shyim.de/image/59?1" width="35">](https://sponsor.shyim.de/profile/59)
[<img src="https://sponsor.shyim.de/image/60?1" width="35">](https://sponsor.shyim.de/profile/60)
[<img src="https://sponsor.shyim.de/image/61?1" width="35">](https://sponsor.shyim.de/profile/61)
[<img src="https://sponsor.shyim.de/image/62?1" width="35">](https://sponsor.shyim.de/profile/62)
[<img src="https://sponsor.shyim.de/image/63?1" width="35">](https://sponsor.shyim.de/profile/63)
[<img src="https://sponsor.shyim.de/image/64?1" width="35">](https://sponsor.shyim.de/profile/64)
[<img src="https://sponsor.shyim.de/image/65?1" width="35">](https://sponsor.shyim.de/profile/65)
[<img src="https://sponsor.shyim.de/image/66?1" width="35">](https://sponsor.shyim.de/profile/66)
[<img src="https://sponsor.shyim.de/image/67?1" width="35">](https://sponsor.shyim.de/profile/67)
[<img src="https://sponsor.shyim.de/image/68?1" width="35">](https://sponsor.shyim.de/profile/68)
[<img src="https://sponsor.shyim.de/image/69?1" width="35">](https://sponsor.shyim.de/profile/69)
[<img src="https://sponsor.shyim.de/image/70?1" width="35">](https://sponsor.shyim.de/profile/70)
[<img src="https://sponsor.shyim.de/image/71?1" width="35">](https://sponsor.shyim.de/profile/71)
[<img src="https://sponsor.shyim.de/image/72?1" width="35">](https://sponsor.shyim.de/profile/72)
[<img src="https://sponsor.shyim.de/image/73?1" width="35">](https://sponsor.shyim.de/profile/73)
[<img src="https://sponsor.shyim.de/image/74?1" width="35">](https://sponsor.shyim.de/profile/74)
[<img src="https://sponsor.shyim.de/image/75?1" width="35">](https://sponsor.shyim.de/profile/75)
[<img src="https://sponsor.shyim.de/image/76?1" width="35">](https://sponsor.shyim.de/profile/76)
[<img src="https://sponsor.shyim.de/image/77?1" width="35">](https://sponsor.shyim.de/profile/77)
[<img src="https://sponsor.shyim.de/image/78?1" width="35">](https://sponsor.shyim.de/profile/78)
[<img src="https://sponsor.shyim.de/image/79?1" width="35">](https://sponsor.shyim.de/profile/79)
[<img src="https://sponsor.shyim.de/image/80?1" width="35">](https://sponsor.shyim.de/profile/80)
[<img src="https://sponsor.shyim.de/image/81?1" width="35">](https://sponsor.shyim.de/profile/81)
[<img src="https://sponsor.shyim.de/image/82?1" width="35">](https://sponsor.shyim.de/profile/82)
[<img src="https://sponsor.shyim.de/image/83?1" width="35">](https://sponsor.shyim.de/profile/83)
[<img src="https://sponsor.shyim.de/image/84?1" width="35">](https://sponsor.shyim.de/profile/84)
[<img src="https://sponsor.shyim.de/image/85?1" width="35">](https://sponsor.shyim.de/profile/85)
[<img src="https://sponsor.shyim.de/image/86?1" width="35">](https://sponsor.shyim.de/profile/86)
[<img src="https://sponsor.shyim.de/image/87?1" width="35">](https://sponsor.shyim.de/profile/87)
[<img src="https://sponsor.shyim.de/image/88?1" width="35">](https://sponsor.shyim.de/profile/88)
[<img src="https://sponsor.shyim.de/image/89?1" width="35">](https://sponsor.shyim.de/profile/89)
[<img src="https://sponsor.shyim.de/image/90?1" width="35">](https://sponsor.shyim.de/profile/90)
[<img src="https://sponsor.shyim.de/image/91?1" width="35">](https://sponsor.shyim.de/profile/91)
[<img src="https://sponsor.shyim.de/image/92?1" width="35">](https://sponsor.shyim.de/profile/92)
[<img src="https://sponsor.shyim.de/image/93?1" width="35">](https://sponsor.shyim.de/profile/93)
[<img src="https://sponsor.shyim.de/image/94?1" width="35">](https://sponsor.shyim.de/profile/94)
[<img src="https://sponsor.shyim.de/image/95?1" width="35">](https://sponsor.shyim.de/profile/95)
[<img src="https://sponsor.shyim.de/image/96?1" width="35">](https://sponsor.shyim.de/profile/96)
[<img src="https://sponsor.shyim.de/image/97?1" width="35">](https://sponsor.shyim.de/profile/97)
[<img src="https://sponsor.shyim.de/image/98?1" width="35">](https://sponsor.shyim.de/profile/98)
[<img src="https://sponsor.shyim.de/image/99?1" width="35">](https://sponsor.shyim.de/profile/99)
