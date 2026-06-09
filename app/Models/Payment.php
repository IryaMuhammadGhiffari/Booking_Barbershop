<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id',
        'order_id',
        'transaction_id',
        'amount',
        'payment_method',
        'status',
        'snap_token',
        'snap_url',
        'midtrans_response',
        'paid_at',
    ];

    protected $casts = [
        'amount'            => 'decimal:2',
        'midtrans_response' => 'array',
        'paid_at'           => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
