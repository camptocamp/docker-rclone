#!/bin/sh

confd -onetime -backend env

exec /usr/bin/rclone $*
