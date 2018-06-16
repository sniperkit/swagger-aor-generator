# Refs
# - https://blog.realkinetic.com/building-minimal-docker-containers-for-python-applications-37d0272c52f3
# - https://github.com/sys3/dockerized-s3cmd/blob/master/Dockerfile

FROM frolvlad/alpine-python3 as base
FROM base as builder

RUN mkdir /install
WORKDIR /install
COPY requirements.txt /requirements.txt

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/install/lib/python3.6/site-packages \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8
    # PYTHONPATH=/install/lib/python3.6/site-packages \

# hints: 
# apk --no-cache --no-progress add build-base cmake g++ linux-headers openssl python3-dev ca-certificates wget vim
# snippets:
# - && pip3 install --upgrade pip \
# - pip3 install --no-cache-dir 
RUN apk --no-cache --no-progress add ca-certificates git libssh2 openssl \
    && mkdir -p /install \
    && pip3 install --install-option="--install-dir=/install" -r /requirements.txt
    #
    #
	# && pip3 install --install-option="--prefix=/install" -r /requirements.txt

FROM base

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/install/lib/python3.6/site-packages \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    GENERATE_DIR=/app/shared/generated

COPY --from=builder /install /usr
COPY src /app
COPY docker /app/docker

WORKDIR /app

CMD ["./docker/entrypoint.sh", "demo-aor"]

# snippets:
# - EXPOSE 80
# - ENTRYPOINT ["/sbin/tini", "--"]
# - CMD ["/app/deploy/entrypoint.sh"]
# - docker build -t swagger-aor-generator:python3.6-alpine --no-cache .