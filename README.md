# shopware-docker

## Why i build it, there are already docker images for shopware?

I have a little bit another use case, i need different php versions for testing. Also i hate apache so i use as webserver everywhere nginx with php-fpm.
Also all images does not contain ioncube, because i dont need it while developing in the core.
Every folder in `~/Code` is a subdomain which makes testing very helpful. ("~/Code/shopware" => http://shopware.localhost)
And at last every thing is designed to use of shopware git version.
