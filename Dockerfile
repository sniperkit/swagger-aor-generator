# References:
# - https://blog.realkinetic.com/building-minimal-docker-containers-for-python-applications-37d0272c52f3
# - https://github.com/sys3/dockerized-s3cmd/blob/master/Dockerfile
# - https://github.com/maur1th/naxos/blob/master/app/forum/Dockerfile
# - https://github.com/frol/docker-alpine-python-machinelearning/blob/master/Dockerfile
# - https://github.com/grammarly/rocker/issues/199
# - https://github.com/veggiemonk/awesome-docker#builder
# - https://docs.docker.com/develop/develop-images/multistage-build/
# - https://gitlab.com/larry1123-builds/rocker
# - https://gist.github.com/Larry1123/b9ad384b16035f4200ee4adb3736b67f
# - https://pkgs.alpinelinux.org/packages?name=python3*&branch=edge

# FROM python:3.6-alpine as base
FROM frolvlad/alpine-python3 as base
FROM base as builder

RUN mkdir -p /install
WORKDIR /install
COPY requirements.txt /requirements.txt


ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=${PYTHONPATH:-"/install/lib/python3.6/site-packages"} \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apk --no-cache --no-progress add ca-certificates git libssh2 openssl build-base python3-dev file binutils \
    && pip install --install-option="--prefix=/install" -r /requirements.txt \
    && rm -r /root/.cache \
    && find /install/lib/python3.*/ -name 'tests' -print -exec rm -r '{}' + \
    && find /install/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; \
    && ls -l /install/lib/python3.6/site-packages

    # && pip3 install -r /requirements.txt --install-option="--prefix='/install'" --target /install \
    # --global-option="--no-user-cfg" --install-option="--prefix='/usr/local'" --install-option="--no-compile"
    # && pip install --install-option="--prefix=/install" -r /requirements.txt \

FROM base

ENV HOME=/app \
    PATH=$PATH:/app/.local/bin \
    \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH="${PYTHONPATH:-"/usr/src:/usr/src/swagger-parser"}" \
    \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    \
    GENERATE_DIR=/app/shared/generated


COPY --from=builder /install /usr
COPY src /app
COPY docker /app/docker
# COPY shared /app/shared

WORKDIR /app

# Container configuration
EXPOSE 3000
VOLUME ["/shared"]

# HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

ENTRYPOINT ["./docker/entrypoint.sh"]
# ENTRYPOINT ["tini", "-g", "--"]