#!/usr/bin/env bash
# Entrypoint untuk Arfan Barbershop API di Render (Docker)
set -e

echo ">>> Preparing .env if missing..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
    fi
fi

echo ">>> Generating APP_KEY if missing..."
php artisan key:generate --force --no-interaction 2>/dev/null || true

echo ">>> Running migrations..."
php artisan migrate --force 2>/dev/null || true

echo ">>> Starting Apache..."
exec apache2-foreground
