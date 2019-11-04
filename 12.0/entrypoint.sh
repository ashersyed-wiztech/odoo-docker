#!/bin/bash

set -e

# sed -i "s|; db_name = |db_name = ${POSTGRESQL_DB}|g" /etc/odoo/odoo.conf
# sed -i "s|; list_db = False|list_db = False|g" /etc/odoo/odoo.conf

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
# : ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
# : ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
# : ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
# : ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$POSTGRESQL_HOST"
check_config "db_port" "$POSTGRESQL_PORT_NUMBER"
check_config "db_user" "$POSTGRESQL_USER"
check_config "db_password" "$POSTGRESQL_PASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

#check persistance 2

exit 1
