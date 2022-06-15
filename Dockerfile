FROM debian:bullseye-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		pdns-server \
		pdns-backend-bind \
		sqlite3 \
		bind9-dnsutils \
	; \
	rm -rf /var/lib/apt/lists/*

ADD start.sh /

EXPOSE 53/tcp 53/udp
VOLUME ["/var/lib/powerdns"]

CMD /start.sh

HEALTHCHECK CMD dig @127.0.0.1 || exit 1
