Docker image for rclone
=======================

This image allows you to backup a directory on an object storage (only s3 and swift supported right now) using rclone.

Usage
-----

```shell
$ docker run camptocamp/rclone
```

```shell
$ docker run -e OS_AUTH_URL=$OS_AUTH_URL -e OS_TENANT_NAME=$OS_TENANT_NAME -e OS_USERNAME=$OS_USERNAME -e OS_PASSWORD=$OS_PASSWORD -e OS_REGION_NAME=$OS_REGION_NAME camptocamp/rclone sync /data swift:backup
```

Environment variables
---------------------

### S3

#### AWS_ACCESS_KEY_ID

#### AWS_SECRET_ACCESS_KEY

#### AWS_DEFAULT_REGION

#### AWS_ENDPOINT

### Swift

#### OS_USERNAME

#### OS_PASSWORD

#### OS_AUTH_URL

#### OS_TENANT_NAME

#### OS_REGION_NAME
