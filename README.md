# nginx-proxy

_nginx-proxy_ sets up a container running [nginx][0] and [docker-gen][1], that
allow for nginx to be reloaded with a new reverse proxy every time a container
is started or stopped.

This image is mostly a copy of [Jason Wilder's](https://github.com/jwilder) [nginx-proxy](https://github.com/jwilder/nginx-proxy) with an upgrade to Debian Jessie and nginx 1.12.

See [Automated Nginx Reverse Proxy for Docker][5] for why you might want to use
this.

## Usage

To run it:

```bash
docker run -d \
    -p 80:80 \
    -v /var/run/docker.sock:/tmp/docker.sock \
    inhortte/nginx-proxy
```

Then start any containers you want proxied with an environment variable
`VIRTUAL_HOST=subdomain.youdomain.com`

```bash
docker run -e VIRTUAL_HOST=foo.bar.com ...
```

Provided your DNS is setup to forward `foo.bar.com` to the a host running
nginx-proxy, the request will be routed to a container with the `VIRTUAL_HOST`
environment variable set.

## Multiple Ports

If your container exposes multiple ports, nginx-proxy will default to the
service running on port 80. If you need to specify a different port, you can set
a `VIRTUAL_PORT` environment variable to select a different one. If your
container only exposes one port and it has a `VIRTUAL_HOST` environment variable
set, that port will be selected.

## Multiple Hosts

If you need to support multiple virtual hosts for a container, you can separate
each entry with commas. For example, `foo.bar.com,baz.bar.com,bar.com` and each
host will be setup the same.

## Volumes

To make it easier to also use this image to serve static content, one can mount
additional configurations files in the folder `/opt/nginx-proxy/sites-static`, and mount a base html directory at `/usr/share/nginx/html`.

By default, [docker-gen][1] will generate configurations based on
[nginx.tmpl][6], if a different template needs to be used, mount a volume in
`/opt/nginx-proxy/nginx` containing the `nginx.tmpl`.

[0]: http://nginx.org/en/
[1]: https://github.com/jwilder/docker-gen
[2]: https://github.com/jwilder/nginx-proxy
[3]: https://github.com/jwilder
[4]: https://registry.hub.docker.com/_/nginx/
[5]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
[6]: https://github.com/joaodubas/nginx-proxy/blob/master/nginx.tmpl
