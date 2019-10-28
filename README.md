# ironpeakservices/iron-nginx
Secure base image for running nginx.

## How is this different?
We build from the official nginx docker image, but additionally:
- an empty scratch container (no shell, unprivileged user, ...) for a tiny attack vector
- hardened nginx config
- hardened Docker Compose file

## Example
```
FROM ironpeakservices/iron-nginx
COPY --chown=nonroot css/ js/ html/ /assets
```