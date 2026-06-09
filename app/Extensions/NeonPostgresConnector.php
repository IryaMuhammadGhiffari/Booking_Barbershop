<?php

namespace App\Extensions;

use Illuminate\Database\Connectors\PostgresConnector;

class NeonPostgresConnector extends PostgresConnector
{
    protected function getDsn(array $config)
    {
        $dsn = parent::getDsn($config);

        if (! empty($config['dsn_options']) && is_string($config['dsn_options'])) {
            $dsn .= ';'.$config['dsn_options'];
        }

        return $dsn;
    }
}
