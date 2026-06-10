#!/usr/bin/env bash
# Render start script for Arfan Barbershop API
set -e

echo ">>> Running migrations..."
php artisan migrate --force --isolated

echo ">>> Clearing cache..."
php artisan optimize:clear

echo ">>> Starting server..."
php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
