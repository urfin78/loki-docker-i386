FROM grafana/loki as buildtrigger
FROM i386/golang:1.12.7-stretch as gobuild
ENV GOPATH=/go/src/app
WORKDIR /go/src/app
RUN go get github.com/grafana/loki; exit 0
WORKDIR /go/src/app/src/github.com/grafana/loki
RUN go build ./cmd/loki

FROM i386/debian:stretch-slim as loki
COPY --from=gobuild /go/src/app/src/github.com/grafana/loki/loki /loki/loki
COPY --from=gobuild /go/src/app/src/github.com/grafana/loki/cmd/loki/loki-local-config.yaml /loki/loki-local-config.yaml
EXPOSE 3100
CMD ["/loki/loki", "-config.file=/loki/loki-local-config.yaml"]
