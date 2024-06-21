FROM openresty/openresty:1.21.4.1-0-focal

ARG user=www-data
ARG group=www-data

RUN luarocks install lua-resty-jit-uuid

RUN mkdir -p /etc/letsencrypt &&\
    mkdir -p /etc/project/ssl &&\
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj '/CN=sni-support-required-for-valid-ssl' \
        -keyout /etc/project/ssl/default.key \
        -out /etc/project/ssl/default.crt

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-auto-ssl 0.13.1 &&\
    mkdir /etc/resty-auto-ssl/ &&\
    chown -R $user:$group /etc/resty-auto-ssl/
    
# COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
# COPY conf/my-lua-script.lua /usr/local/openresty/nginx/conf/my-lua-script.lua


COPY ./nginx/conf /usr/local/openresty/nginx/conf
COPY ./nginx/lualib /usr/local/openresty/nginx/lualib
COPY ./nginx/static /usr/local/openresty/nginx/static

EXPOSE 80 443

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]