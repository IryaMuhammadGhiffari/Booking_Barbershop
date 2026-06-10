import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Admin-specific barber management — CRUD + unavailability.
class AdminBarberProvider with ChangeNotifier {
  final _api = ApiService();

  List _barbers = [];
  bool _isLoading = false;
  String? _error;

  List get barbers => _barbers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetch() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.adminGetBarbers();
      _barbers = res.data['data'] ?? [];
    } catch (e) {
      if (_barbers.isEmpty) {
        _error = 'Gagal memuat data barber';
        if (e is DioException) {
          _error = e.response?.data?['message'] ?? _error;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.createBarber(data);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menambah barber';
      return false;
    } catch (_) {
      _error = 'Gagal menambah barber';
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await _api.updateBarber(id, data);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal mengupdate barber';
      return false;
    } catch (_) {
      _error = 'Gagal mengupdate barber';
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.deleteBarber(id);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menghapus barber';
      return false;
    } catch (_) {
      _error = 'Gagal menghapus barber';
      return false;
    }
  }
}
