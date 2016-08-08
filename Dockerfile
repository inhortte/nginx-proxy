# nginx autogenerator reverse proxy
#
FROM debian:jessie
MAINTAINER inhortte@gmail.com

# environment variables
# ENV NGINX_VERSION 1.7.6-1~wheezy
ENV NGINX_VERSION 1.10.1-1~jessie
ENV DOCKER_HOST unix:///tmp/docker.sock

# install system deps
RUN apt-key adv \
        --keyserver pgp.mit.edu \
        --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
#    && echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" \
    && echo "deb http://nginx.org/packages/debian/ jessie nginx" \
        >> /etc/apt/sources.list \
    && apt-get -y -qq --force-yes update \
    && apt-get --only-upgrade install bash \
    && apt-get -y -qq --force-yes install \
      nginx=${NGINX_VERSION} wget ca-certificates \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ENV DOCKER_GEN_VERSION 0.7.3

# install external deps
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego
RUN wget --no-check-certificate \
    https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# improve default conf for nginx
RUN mkdir /etc/nginx/sites-enabled \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && sed -r -i \
        "s/(\s+)(include \/etc\/nginx\/conf[^\;]+;)/\1\2\n\1include \/etc\/nginx\/sites-enabled\/*;\n\1include \/opt\/nginx-proxy\/sites-static\/*;/g" \
        /etc/nginx/nginx.conf

# add default nginx conf template
ADD https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl /opt/nginx-proxy/default/nginx.tmpl
RUN ln -s /opt/nginx-proxy/default /opt/nginx-proxy/nginx

# configure forego
RUN mkdir -p /opt/nginx-proxy
ADD ./Procfile /opt/nginx-proxy/Procfile

# container conf
EXPOSE 80 443
VOLUME ["/etc/nginx/certs", "/opt/nginx-proxy/nginx", "/opt/nginx-proxy/sites-static", "/usr/share/nginx/html"]
WORKDIR /opt/nginx-proxy
CMD ["forego", "start", "-r"]
