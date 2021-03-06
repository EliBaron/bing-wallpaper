FROM golang:1.10-alpine as builder
ARG VERSION
WORKDIR /go/src/bing-wallpaper
COPY . .
RUN go build -o ./bw/bw ./bw/main.go


FROM alpine
LABEL maintainer="bw"
RUN apk --no-cache add ca-certificates tzdata sqlite \
	&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& echo "Asia/Shanghai" >  /etc/timezone \
	&& apk del tzdata
# See https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN mkdir /bw
WORKDIR /bw
COPY --from=builder /go/src/bing-wallpaper/bw/bw /bw/bw

EXPOSE 9000
ENTRYPOINT ["/bw/bw", "run"]
