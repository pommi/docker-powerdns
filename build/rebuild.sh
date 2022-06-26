#!/bin/sh

updates_available () {
    if test "$(docker run -it --rm $1 /bin/sh -c 'apt -qqq update && apt -qq list --upgradable')" != ""; then
        return 0
    else
        return 1
    fi
}

if updates_available pommib/powerdns:4.4-bullseye; then
    ./debian/11/build.sh
fi

if updates_available pommib/powerdns:4.6-bookworm; then
    ./debian/12/build.sh
fi
