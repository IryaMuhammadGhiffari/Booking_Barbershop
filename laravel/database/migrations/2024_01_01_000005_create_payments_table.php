<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->string('order_id')->unique();
            $table->string('transaction_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->string('payment_method')->nullable();
            $table->enum('status', [
                'pending',
                'paid',
                'failed',
                'expired',
                'refunded'
            ])->default('pending');
            $table->string('snap_token')->nullable();
            $table->string('snap_url')->nullable();
            $table->json('midtrans_response')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
