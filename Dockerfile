FROM sergef/docker-library-alpine:edge

EXPOSE 80 443

ENV NGINX_VERSION 1.12.1-r2

COPY build.sh /build.sh
COPY APKBUILD.patch /APKBUILD.patch

RUN apk add \
    --update-cache \
    alpine-sdk \
    coreutils \
  && adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && mkdir -p /aports \
  && chmod +x /build.sh \
  && chown builder:abuild /aports /build.sh \
  && sudo su - builder /build.sh \
  && cp /home/builder/packages/main/x86_64/* /var/lib/apk \
  && deluser --remove-home builder \
  && mkdir /app /run/nginx \
  && apk add \
    /var/lib/apk/nginx-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-stream-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-http-echo-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-http-lua-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-http-lua-upstream-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-http-headers-more-${NGINX_VERSION}.apk \
    /var/lib/apk/nginx-mod-http-auth-ldap-${NGINX_VERSION}.apk \
  && apk del \
    alpine-sdk \
    coreutils \
  && rm -rf \
    /var/cache/apk/* \
    /var/lib/apk/* \
    /aports

COPY etc/nginx /etc/nginx

ENTRYPOINT ["/sbin/tini","-g","--"]
CMD ["nginx", "-g", "daemon off;"]
