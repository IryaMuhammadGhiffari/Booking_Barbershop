<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminMiddleware
{
    /**
     * Tolak akses jika bukan admin
     */
    public function handle(Request $request, Closure $next)
    {
        if (! $request->user() || ! $request->user()->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya admin yang diizinkan.',
            ], 403);
        }

        return $next($request);
    }
}
