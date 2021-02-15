#!/usr/bin/env bash

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

TRAP_PIDS="/tmp/${SHOPWARE_PROJECT}-worker.pid"
WORKER_AMOUNT=$3

if [[ -z $WORKER_AMOUNT ]]; then
  WORKER_AMOUNT=1;
fi

function cancel_trap()
{
  for i in $(seq 1 ${WORKER_AMOUNT}); do
    PID=$(cat "${TRAP_PIDS}.$i");

    if [[ -n $PID ]]; then
      kill -9 "$PID"
      rm "${TRAP_PIDS}.$i"
    fi
  done
}

trap cancel_trap SIGINT

for i in $(seq 1 ${WORKER_AMOUNT}); do
  bash -c 'while true; do php bin/console messenger:consume --memory-limit=1G; done'  > /dev/null 2>&1 & echo $! > "${TRAP_PIDS}.$i"
done

echo "Started ${WORKER_AMOUNT} Worker in Background. Press STRG+C to cancel them"

wait