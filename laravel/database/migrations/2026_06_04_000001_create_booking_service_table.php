<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('booking_service', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            $table->unique(['booking_id', 'service_id']);
        });

        if (Schema::hasColumn('bookings', 'service_id')) {
            DB::table('bookings')
                ->whereNotNull('service_id')
                ->orderBy('id')
                ->chunk(100, function ($bookings) {
                    foreach ($bookings as $booking) {
                        DB::table('booking_service')->insert([
                            'booking_id' => $booking->id,
                            'service_id' => $booking->service_id,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                });

            Schema::table('bookings', function (Blueprint $table) {
                $table->dropForeign(['service_id']);
                $table->dropColumn('service_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->foreignId('service_id')->nullable()->constrained()->onDelete('cascade');
        });

        DB::table('booking_service')
            ->orderBy('id')
            ->chunk(100, function ($rows) {
                foreach ($rows as $row) {
                    DB::table('bookings')
                        ->where('id', $row->booking_id)
                        ->whereNull('service_id')
                        ->update(['service_id' => $row->service_id]);
                }
            });

        Schema::dropIfExists('booking_service');
    }
};
