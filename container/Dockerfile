FROM alpine:3.17

RUN apk --no-cache --update add openssh gettext curl jq aws-cli \
    && rm -rf /var/cache/apk/*

COPY container-entrypoint.sh /usr/local/bin/

EXPOSE 22

CMD [ "/usr/local/bin/container-entrypoint.sh" ]


