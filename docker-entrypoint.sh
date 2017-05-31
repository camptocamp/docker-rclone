#!/bin/bash

rm -f rclone.log
/usr/bin/rclone "$@" | tee rclone.log


if [ ! -z "${PUSHGATEWAY_URL}" ]; then
  echo "Sending metrics to ${PUSHGATEWAY_URL}"

  if getent hosts rancher-metadata >/dev/null; then
    instance=$(curl http://rancher-metadata/latest/self/container/name)
  else
    instance=$(hostname -f)
  fi

  read src dst < <(sed -n '0,/.*with parameters.* "src:\([^"]\+\)" "dst:\([^"]\+\)"]/ s//\1 \2/p' < <(cat rclone.log))
  transferred_raw=$(sed -n '0,/Transferred: *\([^ ]\+\) \([A-Za-z]\)Bytes.*/ s//\1\2/p' < <(cat rclone.log))
  transferred=$(numfmt --from=iec $transferred_raw)
  errors=$(sed -n '0,/Errors: */ s///p' < <(cat rclone.log))
  checks=$(sed -n '0,/Checks: */ s///p' < <(cat rclone.log))

  cat <<EOF | curl --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/rclone/instance/${instance}/source/${src}/destination/${dst}"
# TYPE rclone gauge
rclone{what="transferred_bytes"} ${transferred}
rclone{what="errors"} ${errors}
rclone{what="checks"} ${checks}
EOF
fi
