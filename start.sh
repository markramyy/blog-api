#!/bin/bash
set -e

wait_for_postgres() {
  echo "Waiting for PostgreSQL to be ready..."
  until PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U postgres -c '\q'; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
  done
  echo "PostgreSQL is up!"
}

wait_for_redis() {
  echo "Waiting for Redis to be ready..."
  until redis-cli -h redis ping; do
    echo "Redis is unavailable - sleeping"
    sleep 1
  done
  echo "Redis is up!"
}

setup_database() {
  echo "Setting up database..."
  bundle exec rails db:create
  bundle exec rails db:migrate
  echo "Database setup completed!"
}

start_rails_server() {
  echo "Starting Rails server..."
  rm -f tmp/pids/server.pid
  bundle exec rails server -p 3000 -b '0.0.0.0'
}

start_sidekiq() {
  echo "Starting Sidekiq..."
  bundle exec sidekiq
}

case "$SERVICE_ROLE" in
  "web")
    wait_for_postgres
    wait_for_redis
    setup_database
    start_rails_server
    ;;
  "sidekiq")
    wait_for_postgres
    wait_for_redis
    start_sidekiq
    ;;
  "test")
    wait_for_postgres
    wait_for_redis
    bundle exec rails db:test:prepare
    bundle exec rspec
    ;;
  *)
    echo "Unknown service role: $SERVICE_ROLE"
    exit 1
    ;;
esac
