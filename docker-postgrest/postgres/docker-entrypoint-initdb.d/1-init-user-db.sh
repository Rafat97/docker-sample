#!/bin/bash
set -e

readonly REQUIRED_ENV_VARS=(
  "NOTROOT_USER"
  "NOTROOT_USER_PASSWORD"
  "NOTROOT_USER_DATABASE"
  "POSTGRES_USER"
  "POSTGRES_DB"
  "POSTGRES_PASSWORD")


main() {
  check_env_vars_set
  init_user_and_db
}

check_env_vars_set() {
  for required_env_var in ${REQUIRED_ENV_VARS[@]}; do
    if [[ -z "${!required_env_var}" ]]; then
      echo "Error:
    Environment variable '$required_env_var' not set.
    Make sure you have the following environment variables set:
      ${REQUIRED_ENV_VARS[@]}
Aborting."
      exit 1
    fi
  done
}


init_user_and_db() {
    
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $NOTROOT_USER WITH PASSWORD '$NOTROOT_USER_PASSWORD';
        CREATE DATABASE $NOTROOT_USER_DATABASE;
        GRANT ALL PRIVILEGES ON DATABASE $NOTROOT_USER_DATABASE TO $NOTROOT_USER;
EOSQL

}

main "$@"