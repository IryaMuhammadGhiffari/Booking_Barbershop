<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BarberUnavailability extends Model
{
    protected $fillable = [
        'barber_id',
        'date',
        'reason',
        'notes',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public const REASON_LABELS = [
        'sick'  => 'Sakit',
        'leave' => 'Izin',
        'off'   => 'Libur / Tidak Masuk',
    ];

    public function barber()
    {
        return $this->belongsTo(Barber::class);
    }

    public function getReasonLabelAttribute(): string
    {
        return self::REASON_LABELS[$this->reason] ?? $this->reason;
    }
}
