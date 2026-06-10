<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $fillable = [
        'booking_code',
        'user_id',
        'barber_id',
        'booking_date',
        'booking_time',
        'total_price',
        'status',
        'notes',
    ];

    protected $casts = [
        'booking_date' => 'date',
        'total_price'  => 'decimal:2',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($booking) {
            $booking->booking_code = 'ARF-' . strtoupper(uniqid());
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function barber()
    {
        return $this->belongsTo(Barber::class);
    }

    public function services()
    {
        return $this->belongsToMany(Service::class, 'booking_service');
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }
}
