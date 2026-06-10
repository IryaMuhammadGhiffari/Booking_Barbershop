<?php

$config = require __DIR__.'/../vendor/laravel/framework/config/database.php';

// Neon PostgreSQL: libpq butuh endpoint ID untuk konek
// Otomatis extract endpoint dari host (ep-xxxx.us-east-2.aws.neon.tech)
$host = env('DB_HOST', '127.0.0.1');
if ($host && str_contains($host, '.neon.tech')) {
    $endpointId = explode('.', $host)[0];
    $host .= " options=endpoint=$endpointId";
}
$config['connections']['pgsql']['host'] = $host;
$config['connections']['pgsql']['sslmode'] = env('DB_SSLMODE', 'prefer');
$config['connections']['pgsql']['options'] = [
    PDO::ATTR_PERSISTENT => env('DB_PERSISTENT', false),
];

return $config;
