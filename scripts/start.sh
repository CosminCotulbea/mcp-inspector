#!/bin/sh
echo
echo "===== Starting... ====="
echo

cd scripts || exit
. ./compose.sh
. ./prepare.sh

if ! $COMPOSE up -d; then
    echo
    echo "===== ERROR: 'up -d' failed, containers not started ====="
    echo
    exit 1
fi

echo
echo "===== Done! ====="
echo
