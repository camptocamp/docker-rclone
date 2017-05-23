FROM alpine

ENV RCLONE_VERSION=1.36 \
  CONFD_VERSION=0.12.0-alpha3

RUN apk add --no-cache wget unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN wget http://downloads.rclone.org/rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  unzip rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  rm rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  mv rclone-*/rclone /usr/bin && \
  rm -rf rclone-*

RUN wget --no-check-certificate https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -O /usr/bin/confd && \
  chmod +x /usr/bin/confd

COPY ./confd /etc/confd
COPY ./docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--help" ]
