ARG BUILD_IMAGE=grafana/loki-build-image:0.13.0
ARG VERSION
ARG GOARCH
FROM --platform=linux/amd64 $BUILD_IMAGE as build
RUN git clone http://github.com/grafana/loki /src/loki
WORKDIR /src/loki
RUN if [ "$VERSION" != "master" ]; then git checkout tags/$VERSION; fi
RUN make clean && GOARCH=$GOARCH make BUILD_IN_CONTAINER=true loki

FROM alpine:3.9
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
LABEL org.opencontainers.image.source=https://github.com/urfin78/loki-docker-i386