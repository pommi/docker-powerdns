#!/bin/bash

/usr/sbin/pdns_server --guardian=no --daemon=no --disable-syslog --log-timestamp=no --write-pid=no &

inotifywait -mqre modify --exclude '\.git' --format '%w%f' "/var/lib/powerdns/zones/" |
    while read -r path; do
        zone=$(basename $path)
        echo [$0] A modification was detected in $path
        echo [$0] Executing \`/usr/bin/pdns_control bind-reload-now $zone\`
        /usr/bin/pdns_control bind-reload-now $zone
    done &

wait -n

exit $?
