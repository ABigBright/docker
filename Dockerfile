FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

RUN useradd -m -s /bin/sh -r -U v2ray

WORKDIR /home/v2ray

ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh /home/v2ray/v2ray.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN set -ex \
    && apk add --no-cache tzdata openssl ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x /home/v2ray/v2ray.sh \
    && /home/v2ray/v2ray.sh "${TARGETPLATFORM}" "${TAG}" \
    # get the gosu binary
    cpu_arch="amd64"; \
    curl -fLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$cpu_arch"; \
    curl -fLo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$cpu_arch.asc"; \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    # fullfill gosu binary exec perm
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
