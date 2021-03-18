ARG BUILD_IMAGE=grafana/loki-build-image:0.12.0
# Directories in this file are referenced from the root of the project not this folder
# This file is intended to be called from the root like so:
# docker build -t grafana/loki -f cmd/loki/Dockerfile .
ARG VERSION
FROM --platform=linux/amd64 $BUILD_IMAGE as build
RUN git clone http://github.com/grafana/loki /src/loki
WORKDIR /src/loki
RUN if [ $VERSION != "master" ]; then git checkout tags/$VERSION; fi
RUN make clean && GOARCH=386 make BUILD_IN_CONTAINER=true loki

FROM alpine:3.13.2
RUN apk add --no-cache ca-certificates
COPY --from=build /src/loki/cmd/loki/loki /usr/bin/loki
COPY --from=build /src/loki/cmd/loki/loki-local-config.yaml /etc/loki/local-config.yaml
RUN addgroup -g 3100 -S loki && adduser -u 3100 -S loki -G loki
RUN mkdir -p /loki && chown -R 3100:3100 /etc/loki /loki
# See https://github.com/grafana/loki/issues/1928
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
USER loki
EXPOSE 3100
ENTRYPOINT [ "/usr/bin/loki" ]
CMD ["-config.file=/etc/loki/local-config.yaml"]
