#!/bin/bash
#
# This runs on the same host as OpenTSDB server, collects TSD server
# performance metrics, and feeds them back into the TSD.
#
INTERVAL=15
while :; do
  echo stats || exit
  sleep $INTERVAL
done | nc -w 30 localhost6 4242 \
    | sed 's/^/put /' \
    | nc -w 30 localhost6 4242
