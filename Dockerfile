FROM debian:buster as module_builder

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y libpcre3-dev zlib1g-dev build-essential wget autoconf libtool libjansson-dev libjwt-dev

ARG NGINX_VERSION=1.18.0

RUN mkdir -p /src
WORKDIR /src
ADD lib /src/ngx-http-auth-jwt-module

RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
RUN tar -xzf nginx-$NGINX_VERSION.tar.gz && rm nginx-$NGINX_VERSION.tar.gz 
RUN ln -sf nginx-$NGINX_VERSION nginx 

WORKDIR /src/nginx
RUN ./configure --with-compat --add-dynamic-module=../ngx-http-auth-jwt-module --with-cc-opt='-std=gnu99'
RUN make modules

FROM nginx:1.18.0
RUN apt-get update && apt-get upgrade -y && apt-get install -y libjwt-dev
COPY --from=module_builder /src/nginx/objs/ngx_http_auth_jwt_module.so /usr/lib/nginx/modules
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/gateway.conf /etc/nginx/conf.d/gateway.conf

EXPOSE 8000
