#!/bin/bash

rm -f rclone.log
/usr/bin/rclone "$@" |& tee rclone.log


if [ ! -z "${PUSHGATEWAY_URL}" ]; then
  echo "Sending metrics to ${PUSHGATEWAY_URL}"

  if getent hosts rancher-metadata >/dev/null; then
    instance=$(curl http://rancher-metadata/latest/self/container/name)
  else
    instance=$(hostname -f)
  fi

  transferred_raw=$(sed -n '/Transferred: *\([^ ]\+\) \([A-Za-z]\?\)Bytes.*/ s//\1\2/p' rclone.log | tail -n1)
  transferred=$(numfmt --from=iec ${transferred_raw^^})
  errors=$(sed -n '/Errors: */ s///p' rclone.log | tail -n1)
  checks=$(sed -n '/Checks: */ s///p' rclone.log | tail -n1)

  src=$(cat /proc/1/cmdline|strings|grep ^src:|cut -d: -f2)
  dst=$(cat /proc/1/cmdline|strings|grep ^dst:|cut -d: -f2)

  cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/rclone/source/${src}/destination/${dst}"
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
