FROM sergef/docker-library-alpine:edge

EXPOSE 80 443

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
    /var/lib/apk/nginx-1.12.0-r2.apk \
    /var/lib/apk/nginx-mod-http-echo-1.12.0-r2.apk \
    /var/lib/apk/nginx-mod-http-lua-1.12.0-r2.apk \
    /var/lib/apk/nginx-mod-http-lua-upstream-1.12.0-r2.apk \
    /var/lib/apk/nginx-mod-http-headers-more-1.12.0-r2.apk \
    /var/lib/apk/nginx-mod-http-auth-ldap-1.12.0-r2.apk \
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
