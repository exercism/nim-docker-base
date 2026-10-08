# target = alpine-latest
FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS base

RUN apk add --no-cache gcc musl-dev

FROM base AS nim_builder
COPY bin/install_nim.sh /build/
RUN apk add --no-cache --virtual=.build-deps \
      curl \
      tar \
      xz \
    && sh /build/install_nim.sh \
    && apk del .build-deps
