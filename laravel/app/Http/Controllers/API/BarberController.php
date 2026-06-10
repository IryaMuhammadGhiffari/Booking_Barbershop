<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Barber;
use App\Models\BarberUnavailability;
use App\Models\Booking;
use Illuminate\Http\Request;

class BarberController extends Controller
{
    /**
     * Ambil semua barber yang aktif beserta layanannya
     */
    public function index()
    {
        $barbers = Barber::where('is_active', true)
            ->with(['services' => fn ($q) => $q->select('services.id', 'services.name', 'services.price', 'services.duration')])
            ->select('id', 'name', 'specialty', 'bio', 'photo', 'experience_years', 'rating', 'is_active')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $barbers,
        ]);
    }

    /**
     * Detail satu barber
     */
    public function show($id)
    {
        $barber = Barber::with(['services' => fn ($q) => $q->select('services.id', 'services.name', 'services.price', 'services.duration')])
            ->select('id', 'name', 'specialty', 'bio', 'photo', 'experience_years', 'rating', 'is_active')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $barber,
        ]);
    }

    /**
     * Cek slot waktu tersedia barber pada tanggal tertentu
     * GET /api/barbers/{id}/available-slots?date=2025-06-01
     */
    public function availableSlots(Request $request, $id)
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
        ]);

        Barber::findOrFail($id);

        $unavailability = BarberUnavailability::where('barber_id', $id)
            ->where('date', $request->date)
            ->first();

        if ($unavailability) {
            return response()->json([
                'success' => true,
                'data'    => [
                    'date'                  => $request->date,
                    'is_unavailable'        => true,
                    'unavailability_reason' => $unavailability->reason,
                    'unavailability_label'  => $unavailability->reason_label,
                    'unavailability_notes'  => $unavailability->notes,
                    'available_slots'       => [],
                    'booked_slots'          => [],
                ],
            ]);
        }

        $allSlots = [
            '10:00', '11:00', '12:00', '13:00', '14:00', '15:00',
            '16:00', '17:00', '18:00', '19:00', '20:00', '21:00',
        ];

        $bookedSlots = Booking::where('barber_id', $id)
            ->where('booking_date', $request->date)
            ->whereNotIn('status', ['cancelled'])
            ->pluck('booking_time')
            ->map(fn($t) => substr($t, 0, 5))
            ->toArray();

        $availableSlots = array_values(array_diff($allSlots, $bookedSlots));

        return response()->json([
            'success' => true,
            'data'    => [
                'date'                  => $request->date,
                'is_unavailable'        => false,
                'unavailability_reason' => null,
                'unavailability_label'  => null,
                'unavailability_notes'  => null,
                'available_slots'       => $availableSlots,
                'booked_slots'          => $bookedSlots,
            ],
        ]);
    }

    /**
     * Daftar tanggal barber tidak tersedia (untuk UI booking)
     * GET /api/barbers/{id}/unavailable-dates?from=2026-06-01&to=2026-06-14
     */
    public function unavailableDates(Request $request, $id)
    {
        $request->validate([
            'from' => 'required|date|after_or_equal:today',
            'to'   => 'required|date|after_or_equal:from',
        ]);

        Barber::findOrFail($id);

        $dates = BarberUnavailability::where('barber_id', $id)
            ->whereBetween('date', [$request->from, $request->to])
            ->orderBy('date')
            ->get()
            ->map(fn($u) => [
                'date'   => $u->date->format('Y-m-d'),
                'reason' => $u->reason,
                'label'  => $u->reason_label,
                'notes'  => $u->notes,
            ]);

        return response()->json([
            'success' => true,
            'data'    => $dates,
        ]);
    }

    /**
     * ADMIN - Semua barber (termasuk tidak aktif)
     */
    public function adminIndex()
    {
        $barbers = Barber::with(['services' => fn ($q) => $q->select('services.id', 'services.name', 'services.price', 'services.duration')])
            ->select('id', 'name', 'specialty', 'bio', 'experience_years', 'rating', 'is_active')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $barbers,
        ]);
    }

    /**
     * ADMIN - Tambah barber baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'name'      => 'required|string|max:255',
            'specialty' => 'required|string|max:255',
        ]);

        $barber = Barber::create([
            'name'             => $request->name,
            'specialty'        => $request->specialty,
            'bio'              => $request->bio,
            'experience_years' => $request->experience_years ?? 0,
            'is_active'        => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Barber berhasil ditambahkan',
            'data'    => $barber,
        ], 201);
    }

    /**
     * ADMIN - Edit barber
     */
    public function update(Request $request, $id)
    {
        $barber = Barber::findOrFail($id);

        $barber->update($request->only([
            'name', 'specialty', 'bio', 'experience_years', 'is_active',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Barber berhasil diperbarui',
            'data'    => $barber->fresh(),
        ]);
    }

    /**
     * ADMIN - Hapus barber
     */
    public function destroy($id)
    {
        Barber::findOrFail($id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Barber berhasil dihapus',
        ]);
    }

    /**
     * ADMIN - Daftar ketidakhadiran barber
     */
    public function adminUnavailabilities($id)
    {
        Barber::findOrFail($id);

        $items = BarberUnavailability::where('barber_id', $id)
            ->where('date', '>=', now()->toDateString())
            ->orderBy('date')
            ->get()
            ->map(fn($u) => [
                'id'           => $u->id,
                'barber_id'    => $u->barber_id,
                'date'         => $u->date->format('Y-m-d'),
                'reason'       => $u->reason,
                'reason_label' => $u->reason_label,
                'notes'        => $u->notes,
            ]);

        return response()->json(['success' => true, 'data' => $items]);
    }

    /**
     * ADMIN - Tambah ketidakhadiran barber
     */
    public function storeUnavailability(Request $request, $id)
    {
        Barber::findOrFail($id);

        $request->validate([
            'date'   => 'required|date|after_or_equal:today',
            'reason' => 'required|in:sick,leave,off',
            'notes'  => 'nullable|string|max:500',
        ]);

        $item = BarberUnavailability::updateOrCreate(
            [
                'barber_id' => $id,
                'date'      => $request->date,
            ],
            [
                'reason' => $request->reason,
                'notes'  => $request->notes,
            ]
        );

        $wasRecentlyCreated = $item->wasRecentlyCreated;

        return response()->json([
            'success' => true,
            'message' => $wasRecentlyCreated
                ? 'Ketidakhadiran barber berhasil ditambahkan'
                : 'Jadwal off berhasil diperbarui',
            'data'    => $item,
        ], $wasRecentlyCreated ? 201 : 200);
    }

    /**
     * ADMIN - Hapus ketidakhadiran barber
     */
    public function destroyUnavailability($id, $unavailabilityId)
    {
        $item = BarberUnavailability::where('barber_id', $id)
            ->findOrFail($unavailabilityId);

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Ketidakhadiran barber berhasil dihapus',
        ]);
    }
}
