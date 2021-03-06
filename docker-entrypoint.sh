#!/bin/bash

set -x

rm -f rclone.log

if [ "$CATTLE_DYNAMIC_PATH" = true ] && [ ! -z "${VOLUME_NAME}" ]; then
  instance=$(curl http://rancher-metadata/latest/self/host/name)
  dynamic_path="${DESTINATION_BUCKET}/${instance}/${VOLUME_NAME}"
  echo "Computed dynamic path: ${dynamic_path}"
  /usr/bin/rclone "$@" dst:$dynamic_path |& tee rclone.log

  src=${VOLUME_NAME}
  dst=${DESTINATION_BUCKET}
else
  /usr/bin/rclone "$@" |& tee rclone.log

  src=$(cat /proc/1/cmdline|strings|grep ^src:|cut -d: -f2 | sed -r 's/\//_/g')
  dst=$(cat /proc/1/cmdline|strings|grep ^dst:|cut -d: -f2 | sed -r 's/\//_/g')
fi

if [ ! -z "${PUSHGATEWAY_URL}" ]; then
  echo "Sending metrics to ${PUSHGATEWAY_URL}"

  if [ ! "$CATTLE_DYNAMIC_PATH" = true ]; then
    if getent hosts rancher-metadata >/dev/null; then
      instance=$(curl http://rancher-metadata/latest/self/container/name)
    else
      instance=$(hostname -f)
    fi
  fi

  transferred_raw=$(grep "Transferred:.*Bytes.*" rclone.log | tail -n1 | awk '{print $2}')
  if [ -z "$transferred_raw" ] ; then
    transferred="0"
  else
    transferred=$(numfmt --from=iec ${transferred_raw^^})
  fi
  errors_logged=$(sed -n '/^Errors: */ s///p' rclone.log | tail -n1 | awk '{print $1}')
  errors=${errors_logged:-"0"}
  checks_logged=$(sed -n '/^Checks: */ s///p' rclone.log | tail -n1 | awk '{print $1}')
  checks=${checks_logged:-"0"}

  cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/rclone/source/${src}/destination/${dst}/instance/${instance}"
# TYPE rclone_transferred_bytes gauge
rclone_transferred_bytes ${transferred}
# TYPE rclone_errors gauge
rclone_errors ${errors}
# TYPE rclone_checks gauge
rclone_checks ${checks}
# TYPE rclone_end_time counter
rclone_end_time $(date +%s)
EOF

echo "Metrics sent."
fi
