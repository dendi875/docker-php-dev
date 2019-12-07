FROM nginx:alpine

ARG ALPINE_MIRROR=https://mirrors.aliyun.com
ARG TIMEZONE=Asia/Shanghai

COPY root /

RUN set -xe; \
    chmod a+x /usr/local/bin/*; \
# Switch to a mirror if given
    if [ -n "$ALPINE_MIRROR" ]; then \
        ALPINE_MIRROR=${ALPINE_MIRROR//\//\\\/}; \
        sed -i "s/http:\/\/dl-cdn.alpinelinux.org/$ALPINE_MIRROR/g" /etc/apk/repositories; \
    fi; \
# Install build dependency packages
    apk add --no-cache tcpdump tzdata; \
# Setup timezone
    if [ -n "$TIMEZONE" ]; then \
        cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime; \
        echo "$TIMEZONE" > /etc/timezone; \
    fi; \
# Remove build dependency packages
    apk del --purge tzdata; \
    rm -rf /var/cache/apk/*

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]