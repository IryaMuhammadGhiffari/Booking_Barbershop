<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Service;
use App\Models\Barber;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ==================== USERS ====================
        User::create([
            'name'     => 'Admin Arfan',
            'email'    => 'admin@arfanbarbershop.com',
            'phone'    => '081234567890',
            'password' => Hash::make('admin123'),
            'role'     => 'admin',
        ]);

        User::create([
            'name'     => 'Budi Santoso',
            'email'    => 'budi@gmail.com',
            'phone'    => '087654321098',
            'password' => Hash::make('user123'),
            'role'     => 'user',
        ]);

        // ==================== SERVICES ====================
        $services = [
            ['name' => 'Regular Haircut',    'price' => 35000,  'duration' => 30, 'description' => 'Potong rambut standar dengan styling'],
            ['name' => 'Premium Haircut',    'price' => 65000,  'duration' => 60, 'description' => 'Potong rambut premium + shampoo + blow dry'],
            ['name' => 'Cukur Jenggot',      'price' => 25000,  'duration' => 20, 'description' => 'Cukur jenggot + hot towel treatment'],
            ['name' => 'Hair & Beard Combo', 'price' => 75000,  'duration' => 60, 'description' => 'Paket potong rambut + cukur jenggot'],
            ['name' => 'Coloring',           'price' => 150000, 'duration' => 90, 'description' => 'Pewarnaan rambut sesuai selera'],
            ['name' => 'Hair Treatment',     'price' => 85000,  'duration' => 60, 'description' => 'Perawatan rambut dengan masker premium'],
            ['name' => 'Kids Haircut',       'price' => 25000,  'duration' => 20, 'description' => 'Potong rambut anak di bawah 12 tahun'],
            ['name' => 'Shaving Hot Towel',  'price' => 45000,  'duration' => 30, 'description' => 'Cukur bersih dengan hot towel dan razor'],
        ];

        foreach ($services as $s) {
            Service::create(array_merge($s, ['is_active' => true]));
        }

        // ==================== BARBERS ====================
        $barbers = [
            [
                'name'             => 'Arfan',
                'specialty'        => 'Fade & Classic Cut',
                'bio'              => 'Barber senior 8 tahun pengalaman. Spesialis fade dan classic barbershop cut.',
                'experience_years' => 8,
                'rating'           => 5.0,
            ],
            [
                'name'             => 'Reza',
                'specialty'        => 'Modern Cut & Coloring',
                'bio'              => 'Spesialis potongan modern dan coloring. 5 tahun pengalaman.',
                'experience_years' => 5,
                'rating'           => 4.8,
            ],
            [
                'name'             => 'Dimas',
                'specialty'        => 'Beard & Shaving',
                'bio'              => 'Ahli cukur jenggot dan shaving tradisional.',
                'experience_years' => 3,
                'rating'           => 4.7,
            ],
        ];

        foreach ($barbers as $b) {
            $barber = Barber::create(array_merge($b, ['is_active' => true]));
            // Setiap barber assign beberapa layanan
            $barber->services()->attach(
                Service::inRandomOrder()->take(4)->pluck('id')
            );
        }
    }
}
