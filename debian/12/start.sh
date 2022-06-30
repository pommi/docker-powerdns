#!/bin/bash

# create sqlite database for DNSSEC
if test ! -e /var/lib/powerdns/bind-dnssec-db.sqlite3; then
    echo [$0] Initializing /var/lib/powerdns/bind-dnssec-db.sqlite3
    /usr/bin/pdnsutil create-bind-db /var/lib/powerdns/bind-dnssec-db.sqlite3
fi
sed -i 's/^# bind-dnssec-db=/bind-dnssec-db=\/var\/lib\/powerdns\/bind-dnssec-db.sqlite3/' /etc/powerdns/pdns.d/bind.conf

# start powerdns server
/usr/sbin/pdns_server --guardian=no --daemon=no --disable-syslog --log-timestamp=no --write-pid=no &

# watch for zone changes
inotifywait -mqre modify --exclude '\.git' --exclude '.*\.swp' --format '%w%f' "/var/lib/powerdns/zones/" |
    while read -r path; do
        zone=$(basename $path)
        echo [$0] A modification was detected in $path
        echo [$0] Executing \`/usr/bin/pdns_control bind-reload-now $zone\`
        /usr/bin/pdns_control bind-reload-now $zone
        if pdnsutil show-zone $zone 2>/dev/null | grep -q "Zone is not actively secured"; then
            echo [$0] Zone is not actively secured, skipping \`pdnsutil rectify-zone $zone\`
        else
            echo [$0] DNSSEC secured zone. Executing \`pdnsutil rectify-zone $zone\`
            /usr/bin/pdnsutil rectify-zone $zone
        fi
    done &

wait -n

exit $?
