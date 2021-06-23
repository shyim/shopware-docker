FROM golang:1.16 as build-env

WORKDIR /go/src/app
RUN git clone --depth 1 https://github.com/mailhog/MailHog.git .
RUN go get -d -v ./...
RUN go build -o /go/bin/app

FROM gcr.io/distroless/base
COPY --from=build-env /go/bin/app /
CMD ["/app"]
EXPOSE 1025 8025