FROM alpine:latest

RUN apk add --no-cache \
	bash \
	curl \
        supervisor \
        openssl \
        ca-certificates \
        unbound \
        drill

COPY overlay /

RUN chmod +x /opt/scripts/* /etc/periodic/*/*

EXPOSE 53

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
