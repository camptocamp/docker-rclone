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

  read src dst < <(sed -n '/.*with parameters.* "src:\([^"]\+\)" "dst:\([^"]\+\)"]/ s//\1 \2/p' rclone.log | tail -n1)
  transferred_raw=$(sed -n '/Transferred: *\([^ ]\+\) \([A-Za-z]\?\)Bytes.*/ s//\1\2/p' rclone.log | tail -n1)
  transferred=$(numfmt --from=iec $transferred_raw)
  errors=$(sed -n '/Errors: */ s///p' rclone.log | tail -n1)
  checks=$(sed -n '/Checks: */ s///p' rclone.log | tail -n1)

  cat <<EOF | curl --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/rclone/instance/${instance}/source/${src}/destination/${dst}"
# TYPE rclone gauge
rclone{what="transferred_bytes"} ${transferred}
rclone{what="errors"} ${errors}
rclone{what="checks"} ${checks}
EOF
fi
