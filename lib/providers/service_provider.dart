// lib/providers/service_provider.dart
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

/// Manages service catalog data — isolated from other concerns.
class ServiceProvider with ChangeNotifier {
  final _api = ApiService();

  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const _staleDuration = Duration(minutes: 2);

  /// Fetch services from API.
  /// Set [force] = true to bypass client-side staleness check.
  Future<void> fetchServices({bool force = false}) async {
    // Gunakan cache 2 menit agar tidak fetch berulang
    if (!force && _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _staleDuration &&
        _services.isNotEmpty) {
      return;
    }

    _error = null;
    if (_services.isEmpty) _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getServices();
      _services = (res.data['data'] as List)
          .map((s) => ServiceModel.fromJson(s))
          .toList();
      _lastFetched = DateTime.now();
      _error = null;
    } catch (e) {
      if (_services.isEmpty) {
        _error = e is Exception ? _parseError(e) : 'Gagal memuat layanan';
      }
      // Jika sudah punya data cache, jangan timpa dengan error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    try {
      if (e is Exception) {
        // DioException handling
        final response = (e as dynamic).response;
        if (response != null) {
          return response.data?['message'] ?? 'Gagal memuat layanan';
        }
      }
      return 'Gagal memuat layanan. Periksa koneksi.';
    } catch (_) {
      return 'Gagal memuat layanan';
    }
  }
}
