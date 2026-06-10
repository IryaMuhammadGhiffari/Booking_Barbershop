<?php

$config = require __DIR__.'/../vendor/laravel/framework/config/database.php';

$config['connections']['pgsql']['sslmode'] = env('DB_SSLMODE', 'prefer');
$dsnOpts = env('DB_DSN_OPTIONS');
if ($dsnOpts) {
    // Neon: tambahkan endpoint ID ke DSN via host agar libpq bisa konek
    $config['connections']['pgsql']['host'] .= ' '.$dsnOpts;
}
$config['connections']['pgsql']['options'] = [
    PDO::ATTR_PERSISTENT => env('DB_PERSISTENT', false),
];
// Neon: cold start sangat lambat — pakai PostgreSQL lokal untuk development lebih cepat
// 1. Install PostgreSQL: https://www.postgresql.org/download/windows/
// 2. Buat database: arfan_barbershop
// 3. Copy .env → .env.neon, lalu ubah .env:
//    DB_HOST=localhost
//    DB_PORT=5432
//    DB_DATABASE=arfan_barbershop
//    DB_USERNAME=postgres
//    DB_PASSWORD=postgres
//    DB_SSLMODE=prefer
//    DB_PERSISTENT=true

return $config;
