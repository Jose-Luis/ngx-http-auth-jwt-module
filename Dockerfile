FROM ubuntu:20.04

LABEL maintainer="TeslaGov" email="developers@teslagov.com"

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/share/pkgconfig

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y autoconf
RUN apt-get install -y libtool
RUN apt-get install -y libjansson-dev
RUN apt-get install -y libjwt-dev
#RUN apt-get install -y libssl-dev
#RUN apt-get install -y libxml2-dev
#RUN apt-get install -y libxslt1-dev
#RUN apt-get install -y libgd-dev

ARG NGINX_VERSION=1.18.0

RUN mkdir -p /root/dl
WORKDIR /root/dl
ADD . /root/dl/ngx-http-auth-jwt-module

RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
RUN tar -xzf nginx-$NGINX_VERSION.tar.gz && rm nginx-$NGINX_VERSION.tar.gz 
RUN ln -sf nginx-$NGINX_VERSION nginx 

WORKDIR /root/dl/nginx
RUN ./configure --with-compat --add-dynamic-module=../ngx-http-auth-jwt-module --with-cc-opt='-std=gnu99'
#RUN ./configure --with-compat --add-dynamic-module=../ngx-http-auth-jwt-module --with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-5J5hor/nginx-1.18.0=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-compat --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-mail=dynamic --with-mail_ssl_module
RUN make modules
RUN cp objs/ngx_http_auth_jwt_module.so /usr/lib/nginx/modules/
COPY resources/nginx.conf /etc/nginx/nginx.conf
COPY resources/test-jwt-nginx.conf /etc/nginx/conf.d/test-jwt-nginx.conf
RUN cp -r /root/dl/nginx/html /usr/share/nginx
RUN cp -r /usr/share/nginx/html /usr/share/nginx/secure
RUN cp -r /usr/share/nginx/html /usr/share/nginx/secure-rs256
RUN cp -r /usr/share/nginx/html /usr/share/nginx/secure-auth-header
RUN cp -r /usr/share/nginx/html /usr/share/nginx/secure-no-redirect

ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/usr/sbin/nginx"]

EXPOSE 8000

