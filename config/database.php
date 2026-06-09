<?php

$config = require __DIR__.'/../vendor/laravel/framework/config/database.php';

$config['connections']['pgsql']['sslmode'] = env('DB_SSLMODE', 'require');
$config['connections']['pgsql']['dsn_options'] = env('DB_DSN_OPTIONS');

return $config;
