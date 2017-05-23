Docker image for rclone
=======================

This image allows you to backup a directory on an object storage using rclone.

Usage
-----

```shell
$ docker run camptocamp/rclone
```

```shell
$ docker run \
  -e RCLONE_CONFIG_MYS3_TYPE=s3 \
  -e RCLONE_CONFIG_MYS3_ACCESS_KEY_ID=XXX \
  -e RCLONE_CONFIG_MYS3_SECRET_ACCESS_KEY=XXX \
  camptocamp/rclone lsd MYS3:
```

Environment variables
---------------------

See https://rclone.org/docs/#environment-variables
