<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Barber extends Model
{
    protected $fillable = [
        'name',
        'specialty',
        'bio',
        'photo',
        'experience_years',
        'rating',
        'is_active',
        'working_hours',
    ];

    protected $casts = [
        'is_active'     => 'boolean',
        'working_hours' => 'array',
        'rating'        => 'decimal:2',
    ];

    // Relasi: satu barber bisa punya banyak layanan
    public function services()
    {
        return $this->belongsToMany(Service::class);
    }

    // Relasi: satu barber punya banyak booking
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function unavailabilities()
    {
        return $this->hasMany(BarberUnavailability::class);
    }
}
