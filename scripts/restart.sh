#!/bin/sh
echo
echo "===== Restarting... ====="
echo

cd scripts || exit
. ./compose.sh
. ./prepare.sh

$COMPOSE restart

echo
echo "===== Done! ====="
echo
