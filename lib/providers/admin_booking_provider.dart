// lib/providers/admin_booking_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/api_list_helper.dart';

/// Admin-specific booking management — separate from user's BookingProvider.
class AdminBookingProvider with ChangeNotifier {
  final _api = ApiService();

  List _allBookings = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  String _filter = 'all';

  /// Mengembalikan booking yang sudah difilter sesuai [_filter] (filter lokal).
  List get bookings {
    if (_filter == 'all') return _allBookings;
    return _allBookings.where((b) => b['status'] == _filter).toList();
  }

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  String get filter => _filter;

  /// Ganti filter — langsung update UI via filter lokal, TANPA fetch ulang.
  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  /// Fetch SEMUA booking (tanpa filter status) dari server.
  /// Filter dilakukan secara lokal via getter [bookings].
  Future<void> fetch() async {
    if (_isLoading) return;
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.adminGetBookings(); // tanpa status → ambil semua
      _allBookings = apiDataAsList(res.data['data']);
      _error = null;
    } catch (e) {
      String msg = 'Gagal memuat booking';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      if (_allBookings.isEmpty) _error = msg;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int bookingId, String newStatus) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();
    try {
      await _api.adminUpdateStatus(bookingId, newStatus);
      await fetch(); // refresh list setelah update
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal memperbarui status';
      return false;
    } catch (_) {
      _error = 'Gagal memperbarui status';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
