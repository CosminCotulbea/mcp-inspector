#!/bin/sh
echo
echo "===== Starting... ====="
echo

cd scripts || exit
. ./compose.sh
. ./prepare.sh

$COMPOSE up -d

echo
echo "===== Done! ====="
echo
