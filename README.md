# PowerDNS Docker container

* Debian slim based image
* PowerDNS package from Debian
* Bind backend support only
* DNSSEC support (optional per zone)

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

# DNSSEC

Securing a zone:
```
$ docker exec -it powerdns pdnsutil secure-zone example.tld
[bindbackend] Done parsing domains, 0 rejected, 1 new, 0 removed
Securing zone with default key size
Adding CSK (257) with algorithm ecdsa256
Zone example.tld secured
Adding NSEC ordering information
```

Show DNSSEC related settings for the secured zone:
```
$ docker exec -it powerdns pdnsutil show-zone example.tld
[bindbackend] Done parsing domains, 0 rejected, 1 new, 0 removed
This is a Master zone
Last SOA serial number we notified: 0 != 2022010101 (serial in the database)
Metadata items: None
Zone has NSEC semantics
keys:
ID = 1 (CSK), flags = 257, tag = 280, algo = 13, bits = 256	  Active	 Published  ( ECDSAP256SHA256 )
CSK DNSKEY = example.tld. IN DNSKEY 257 3 13 5jAoLVZFaevgJkAKQzLJDdhQKP1i+SPaCrCjhsbsOAypYSsz9l7AyJC75trKdVwUn9ICMNq6Jjta9NQc7Bnktw== ; ( ECDSAP256SHA256 )
DS = example.tld. IN DS 280 13 1 0dead339b7dacebb6750c7d4e5c9c0f4c19843a9 ; ( SHA1 digest )
DS = example.tld. IN DS 280 13 2 f340e93c42b3c2c6fa8ef76e044ad2f064c1cd7484e785bdfca0f51cd548c88d ; ( SHA256 digest )
DS = example.tld. IN DS 280 13 4 a793c7e590a7701c7b39365f99655b865d11961c355a5eb59302282cf653aec8b051ddc9e36a9df0843cad29ca50149a ; ( SHA-384 digest )
```
