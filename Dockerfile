############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

# Fetch dependencies.
# Using go get.
RUN go get github.com/blueimp/mjpeg-server
# Build the binary.
WORKDIR $GOPATH/src/github.com/blueimp/mjpeg-server
RUN go build -o /go/bin/mjpeg-server





FROM alpine:3.16 AS s6-alpine
LABEL maintainer="Aleksandar Puharic xzero@elite7haers.net"

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

# s6 overlay Download
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Build and some of image configuration
RUN apk upgrade --update --no-cache \
    && rm -rf /var/cache/apk/* \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

# Init
ENTRYPOINT [ "/init" ]

# Install go
COPY --from=builder /go/bin/mjpeg-server /go/bin/mjpeg-server

RUN apk add --no-cache curl 

EXPOSE 9000 9001