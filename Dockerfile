FROM golang:1.13-alpine as builder

RUN apk add --no-cache build-base git

RUN git clone https://github.com/dizzyd/mcdex /mcdex 
RUN cd /mcdex && go build .

FROM alpine:3

RUN apk add --no-cache bash curl jq zip openjdk11-jre-headless
COPY --from=builder /mcdex/mcdex /usr/local/bin/

COPY builder.sh /usr/local/bin/builder
RUN chmod +x /usr/local/bin/builder

VOLUME [ "/builder" ]

ENTRYPOINT [ "builder" ]