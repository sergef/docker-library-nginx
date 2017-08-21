# Docker base images

## NGINX

Building nginx from aports master branch
https://github.com/alpinelinux/aports.git with some customizations.

Added nginx-auth-ldap module from https://github.com/kvspb/nginx-auth-ldap
by patching APKBUILD (will require future maintenance or pull request for aports).

To see all configured modules:

```
nginx -V
```

Modules built with the image:

```
ndk_http_module.so
ngx_http_echo_module.so
ngx_http_lua_module.so
ngx_stream_module.so
ngx_http_auth_ldap_module.so
ngx_http_headers_more_filter_module.so
ngx_http_lua_upstream_module.so
```

Basic nginx configuration included in etc/nginx,
to extend the config put .conf file(s) to etc/nginx/conf.d/http
folder of docker images derived from this image.

### LDAP auth configuration

example:

```
...

http {

  ...

  ldap_server ldapserver {
    url ldap://domain.name/OU=Users,DC=domain,DC=name?sAMAccountName?sub?(objectClass=person);
    binddn ldap_read@domain.name;
    binddn_passwd ********;
    require valid_user;
  }

  server {

    ...

    location /secure/ {

      ...

      auth_ldap "Forbidden";
      auth_ldap_servers ldapserver;

      ...

      proxy_pass http://somewhere;

      ...
    }
  }
}
```
