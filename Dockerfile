ARG REPO=alpine
ARG IMAGE=3.19.1@sha256:6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0
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
