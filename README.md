# PowerDNS Docker container

* Debian slim based image
* PowerDNS package from Debian
* Bind backend support only

# Usage

```
$ mkdir zones
$ cat > zones/example.tld <<EOT
\$TTL    3600
@       IN      SOA     ns1.example.tld. hostmaster.example.tld. (
                        2022010101      ; Serial
                        8H              ; Refresh
                        1H              ; Retry
                        1W              ; Expire
                        1H )            ; Negative Cache TTL

                NS      ns1.example.tld.

                A       192.0.2.1
                AAAA    2001:db8::1
EOT
$ cat > named.conf <<EOT
zone "example.tld" { type master; file "/var/lib/powerdns/zones/example.tld"; allow-query { any; }; };
EOT

$ docker run -it \
    --name powerdns \
    -v $(pwd)/named.conf:/etc/powerdns/named.conf \
    -v $(pwd)/zones/:/var/lib/powerdns/zones/ \
    -p 5353:53/udp -p 5353:53 \
    pommib/powerdns:4.4-bullseye

$ dig +short @127.0.0.1 -p5353 example.tld A
192.0.2.1
```

# docker-compose

```
version: "3"

services:
  powerdns:
    container_name: powerdns
    image: pommib/powerdns:4.4-bullseye
    ports:
      - "5353:53/tcp"
      - "5353:53/udp"
    volumes:
      - '${PWD}/named.conf:/etc/powerdns/named.conf'
      - '${PWD}/zones/:/var/lib/powerdns/zones/'
```
