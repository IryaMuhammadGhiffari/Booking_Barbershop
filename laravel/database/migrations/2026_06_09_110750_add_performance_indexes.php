<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // bookings: filtering by status, date, and conflict checks
        Schema::table('bookings', function (Blueprint $table) {
            $table->index('status');
            $table->index('booking_date');
            $table->index(['booking_date', 'status']);
            $table->index(['barber_id', 'booking_date', 'status'], 'idx_booking_conflict');
        });

        // payments: revenue reports, status filtering
        Schema::table('payments', function (Blueprint $table) {
            $table->index('status');
            $table->index('paid_at');
            $table->index(['status', 'paid_at'], 'idx_payment_revenue');
        });

        // services: user-facing active filter
        Schema::table('services', function (Blueprint $table) {
            $table->index('is_active');
        });

        // barbers: user-facing active filter
        Schema::table('barbers', function (Blueprint $table) {
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['booking_date']);
            $table->dropIndex(['booking_date', 'status']);
            $table->dropIndex('idx_booking_conflict');
        });

        Schema::table('payments', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['paid_at']);
            $table->dropIndex('idx_payment_revenue');
        });

        Schema::table('services', function (Blueprint $table) {
            $table->dropIndex(['is_active']);
        });

        Schema::table('barbers', function (Blueprint $table) {
            $table->dropIndex(['is_active']);
        });
    }
};
