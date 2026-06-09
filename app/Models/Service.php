<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $fillable = [
        'name',
        'description',
        'price',
        'duration',
        'image',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'price'     => 'decimal:2',
    ];

    // Relasi: satu layanan bisa dimiliki banyak barber
    public function barbers()
    {
        return $this->belongsToMany(Barber::class);
    }

    public function bookings()
    {
        return $this->belongsToMany(Booking::class, 'booking_service');
    }
}
