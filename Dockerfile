# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04

ARG FLUTTER_VERSION

LABEL org.opencontainers.image.source="https://github.com/mrkh97/flutter-web-builder"
LABEL org.opencontainers.image.title="flutter-web-builder"
LABEL org.opencontainers.image.description="Pre-baked Flutter SDK for building Flutter web apps in CI/Coolify."
LABEL org.opencontainers.image.licenses="MIT"
LABEL flutter.version="${FLUTTER_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      unzip \
      xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN test -n "${FLUTTER_VERSION}" \
    || (echo "ERROR: build-arg FLUTTER_VERSION is required" >&2 && exit 1)

RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /flutter \
 && git config --global --add safe.directory /flutter

ENV PATH="/flutter/bin:${PATH}"
ENV PUB_CACHE="/root/.pub-cache"

RUN flutter --version \
 && flutter config --no-analytics \
 && flutter precache --web

WORKDIR /app
