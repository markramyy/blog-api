#!/bin/bash
set -e

rm -f /rails/tmp/pids/server.pid

until PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U postgres -c '\q'; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - executing command"

exec "$@"
