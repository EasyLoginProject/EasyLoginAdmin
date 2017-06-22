#!/bin/bash

SRC=$(dirname "${0}")

for path in "${SRC}/Vendors/EasyLoginFrameworkForMac" "${SRC}/Vendors/EasyLoginFrameworkForMac/Vendors/SocketRocket"
do
    echo "Running submodule init and update in ${path}"
    cd "${path}"
    git submodule init
    git submodule update
    cd -
done

exit 0
