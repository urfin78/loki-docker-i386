FROM grafana/loki as buildtrigger
FROM i386/golang:1.13-buster as gobuild
ENV GOPATH=/go/src/app
WORKDIR /go/src/app
RUN go get github.com/grafana/loki; exit 0
WORKDIR /go/src/app/src/github.com/grafana/loki
RUN go build ./cmd/loki

FROM i386/debian:stretch-slim as loki
RUN groupadd -g 3100 loki && useradd -u 3100 --no-create-home -s /bin/false --no-log-init -g loki loki
COPY --from=gobuild --chown=3100:3100 /go/src/app/src/github.com/grafana/loki/loki /loki/loki
COPY loki-local-config.yaml /loki/loki-local-config.yaml
USER 3100:3100
EXPOSE 3100
CMD ["/loki/loki", "-config.file=/loki/loki-local-config.yaml"]
