#!/bin/sh

USER=v2ray

if [ $USER -eq `id -nu` ]; then # container run with user v2ray, allow --user run container
    exec /usr/bin/v2ray "$@"
else
    exec gosu $USER /usr/bin/v2ray "$@"
fi
