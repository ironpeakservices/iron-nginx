# image used for the healthcheck binary
FROM golang:1.13.6-alpine AS gobuilder
COPY healthcheck/ /go/src/healthcheck/
RUN CGO_ENABLED=0 go build -ldflags '-w -s -extldflags "-static"' -o /healthcheck /go/src/healthcheck/

#
# ---
#

# image used to copy our official nginx binaries
FROM nginx:1.17.7 AS base

# create empty index page
RUN echo 'Hello world' > /index.html

# copy the required libraries out of the official nginx image (based on debian)
RUN rm -r /opt && mkdir /opt \
    && cp -a --parents /usr/lib/nginx /opt \
    && cp -a --parents /var/cache/nginx /opt \
    && cp -a --parents /usr/share/nginx /opt \
    && cp -a --parents /usr/sbin/nginx /opt \
    && cp -a --parents /var/log/nginx /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libpcre.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libz.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libc.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libdl.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libpthread.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libcrypt.so.* /opt \
    && cp -a --parents /usr/lib/x86_64-linux-gnu/libssl.so.* /opt \
    && cp -a --parents /usr/lib/x86_64-linux-gnu/libcrypto.so.* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libdl-* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libpthread-* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libcrypt-* /opt \
    && cp -a --parents /lib/x86_64-linux-gnu/libc-* /opt

#
# ---
#

# start from the distroless scratch image (with glibc), based on debian:buster
FROM gcr.io/distroless/base-debian10:nonroot

# copy our empty index page
COPY --from=base --chown=nonroot /index.html /assets/index.html

# copy in our healthcheck binary
COPY --from=gobuilder --chown=nonroot /healthcheck /healthcheck

# copy in our required libraries
COPY --from=base --chown=nonroot /opt /

# copy our config files
COPY --chown=nonroot mime.types nginx.conf /

# run as an unprivileged user
USER nonroot

# default nginx port
EXPOSE 8080

# healthcheck to report the container status
HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD [ "/healthcheck", "8080" ]

# entrypoint
CMD ["/usr/sbin/nginx", "-p", "/tmp/", "-g", "error_log /dev/stderr notice;", "-c", "/nginx.conf"]