<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    /**
     * Ambil semua layanan yang aktif (untuk user)
     */
    public function index()
    {
        $services = Service::where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'data'    => $services,
        ]);
    }

    /**
     * Detail satu layanan
     */
    public function show($id)
    {
        $service = Service::findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $service,
        ]);
    }

    /**
     * ADMIN - Tambah layanan baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'price'    => 'required|numeric|min:0',
            'duration' => 'required|integer|min:1',
        ]);

        $service = Service::create([
            'name'        => $request->name,
            'description' => $request->description,
            'price'       => $request->price,
            'duration'    => $request->duration,
            'is_active'   => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil ditambahkan',
            'data'    => $service,
        ], 201);
    }

    /**
     * ADMIN - Edit layanan
     */
    public function update(Request $request, $id)
    {
        $service = Service::findOrFail($id);

        $service->update($request->only([
            'name', 'description', 'price', 'duration', 'is_active',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil diperbarui',
            'data'    => $service->fresh(),
        ]);
    }

    /**
     * ADMIN - Hapus layanan
     */
    public function destroy($id)
    {
        Service::findOrFail($id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil dihapus',
        ]);
    }
}
