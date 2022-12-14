#!/usr/bin/env bash

SNAP_SUFFIX="$3"
SNAP_DIR="${CODE_DIRECTORY}/snapshots"
CONTAINER="$4"
ARGS=()

if [[ -z "$CONTAINER" ]]; then
  CONTAINER="mysql"
fi

shift 3
while (($#)); do
  case "$1" in
  --force)
    ARGS+=("--force")
    ;;
  esac
  shift
done

if [[ -n "$SNAP_SUFFIX" ]]; then
  SNAP_SUFFIX=$(echo "-${SNAP_SUFFIX}")
fi

if [[ ! -d "$SNAP_DIR" ]]; then
  mkdir "$SNAP_DIR"
fi

checkParameter
if [[ ! -f "$SNAP_DIR/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql" ]]; then
  echo "Snap for shop ${SHOPWARE_PROJECT} does not exists"
  exit 1
fi

echo "DROP DATABASE $SHOPWARE_PROJECT; CREATE DATABASE $SHOPWARE_PROJECT;" | compose exec -T "$CONTAINER" mysql -uroot -p"${MYSQL_ROOT_PASSWORD}"
compose exec -T "$CONTAINER" mysql "${ARGS[@]}" -uroot -p"${MYSQL_ROOT_PASSWORD}" "${SHOPWARE_PROJECT}" <"${SNAP_DIR}/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql"
