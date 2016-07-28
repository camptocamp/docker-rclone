Docker image for rclone
=======================

This image allows you to backup a directory on an object storage (only swift supported right now) using rclone.

Usage
-----

```shell
$ docker run camptocamp/rclone
```

```shell
$ docker run -e OS_AUTH_URL=$OS_AUTH_URL -e OS_TENANT_NAME=$OS_TENANT_NAME -e OS_USERNAME=$OS_USERNAME -e OS_PASSWORD=$OS_PASSWORD -e OS_REGION_NAME=$OS_REGION_NAME camptocamp/rclone sync /data swift:backup
```
