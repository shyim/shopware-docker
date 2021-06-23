FROM golang:1.16 as build-env

WORKDIR /go/src/app
COPY main.go /go/src/app
RUN go get -d -v ./...
RUN go build -a -tags netgo -ldflags '-w' -o /go/bin/app

FROM scratch
COPY --from=build-env /go/bin/app /sendmail