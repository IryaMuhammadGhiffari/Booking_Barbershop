<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('barbers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('specialty')->nullable();
            $table->text('bio')->nullable();
            $table->string('photo')->nullable();
            $table->integer('experience_years')->default(0);
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->boolean('is_active')->default(true);
            $table->json('working_hours')->nullable();
            $table->timestamps();
        });

        // Tabel pivot barber ↔ service
        Schema::create('barber_service', function (Blueprint $table) {
            $table->id();
            $table->foreignId('barber_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_id')->constrained()->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('barber_service');
        Schema::dropIfExists('barbers');
    }
};
