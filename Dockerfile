# image used to copy our official nginx binaries
FROM nginx:1.17.5 AS base

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

# copy in our required libraries
COPY --from=base --chown=nonroot /opt /

# copy our config files
COPY --chown=nonroot mime.types nginx.conf /

# run as an unprivileged user
USER nonroot

# default nginx port
EXPOSE 8080

# entrypoint
ENTRYPOINT ["/usr/sbin/nginx", "-p", "/tmp/", "-g", "error_log /dev/stderr notice;", "-c", "/nginx.conf"]