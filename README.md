# ironpeakservices/iron-nginx
Secure base image for running nginx.

`docker pull docker.pkg.github.com/ironpeakservices/iron-nginx/iron-nginx:1.17.5`

## How is this different?
We build from the official nginx docker image, but additionally:
- an empty scratch container (no shell, unprivileged user, ...) for a tiny attack vector
- secure healthcheck binary for embedded container monitoring
- hardened nginx config
- hardened Docker Compose file
- max memory set to 1GB

## Example
```
FROM docker.pkg.github.com/ironpeakservices/iron-nginx/iron-nginx:1.17.5
COPY --chown=nonroot css/ js/ html/ /assets
```
