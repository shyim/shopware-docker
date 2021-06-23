# Sendmail replacement 

## Why?

- ssmtp and busybox sendmail does not work currently anymore with PHP 8 as they handle mails wrong
  - https://bugs.php.net/bug.php?id=81158

## How to use it?

- Compile the binary by own or copy it out from the Docker image
- Set env variable `SMTP_ADDRESS` to the smtp server.
- Set PHP `sendmail_path` to this binary
- You can now use `mail` function as usual