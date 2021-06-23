FROM golang:1.16 as build-env

WORKDIR /go/src/app
COPY . /go/src/app
RUN go build -tags netgo -ldflags '-w' -o /go/bin/app

FROM scratch
COPY --from=build-env /go/bin/app /sendmail