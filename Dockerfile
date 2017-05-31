FROM alpine

ENV RCLONE_VERSION=1.36

RUN apk add --no-cache wget unzip ca-certificates curl

RUN wget http://downloads.rclone.org/rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  unzip rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  rm rclone-v${RCLONE_VERSION}-linux-amd64.zip && \
  mv rclone-*/rclone /usr/bin && \
  rm -rf rclone-*

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--help" ]
