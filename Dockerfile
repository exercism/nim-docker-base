ARG REPO=alpine
ARG IMAGE=3.15.3@sha256:1e014f84205d569a5cc3be4e108ca614055f7e21d11928946113ab3f36054801
FROM ${REPO}:${IMAGE} AS base
# We can't reliably pin the package versions on Alpine, so we ignore the linter warning.
# See https://gitlab.alpinelinux.org/alpine/abuild/-/issues/9996
# hadolint ignore=DL3018
RUN apk add --no-cache \
      gcc \
      musl-dev

FROM base AS nim_builder
COPY bin/install_nim.sh /build/
# hadolint ignore=DL3018
RUN apk add --no-cache --virtual=.build-deps \
      curl \
      tar \
      xz \
    && sh /build/install_nim.sh \
    && apk del .build-deps
