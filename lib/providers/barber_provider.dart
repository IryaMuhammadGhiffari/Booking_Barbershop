// lib/providers/barber_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barber_model.dart';
import '../services/api_service.dart';

class BarberUnavailableDate {
  final String date;
  final String reason;
  final String label;
  final String? notes;

  BarberUnavailableDate({
    required this.date,
    required this.reason,
    required this.label,
    this.notes,
  });

  factory BarberUnavailableDate.fromJson(Map<String, dynamic> json) {
    String rawDate = json['date']?.toString() ?? '';
    String normalized = rawDate;
    try {
      normalized = DateFormat('yyyy-MM-dd').format(DateTime.parse(rawDate));
    } catch (_) {
      if (rawDate.length >= 10) normalized = rawDate.substring(0, 10);
    }

    return BarberUnavailableDate(
      date: normalized,
      reason: json['reason'],
      label: json['label'] ?? json['reason_label'] ?? json['reason'],
      notes: json['notes'],
    );
  }
}

/// Manages barber catalog, available slots, and unavailability.
class BarberProvider with ChangeNotifier {
  final _api = ApiService();

  List<BarberModel> _barbers = [];
  List<String> _availableSlots = [];
  List<BarberUnavailableDate> _unavailableDates = [];
  bool _isBarberUnavailable = false;
  String? _unavailabilityLabel;
  String? _slotsError;

  bool _isLoadingBarbers = false;
  bool _isLoadingSlots = false;
  String? _barbersError;
  DateTime? _lastBarbersFetch;

  List<BarberModel> get barbers => _barbers;
  List<String> get availableSlots => _availableSlots;
  List<BarberUnavailableDate> get unavailableDates => _unavailableDates;
  bool get isBarberUnavailable => _isBarberUnavailable;
  String? get unavailabilityLabel => _unavailabilityLabel;
  String? get slotsError => _slotsError;
  bool get isLoadingBarbers => _isLoadingBarbers;
  bool get isLoadingSlots => _isLoadingSlots;
  String? get barbersError => _barbersError;

  static const _staleDuration = Duration(minutes: 2);

  // ── BARBERS ────────────────────────────────────────────────

  Future<void> fetchBarbers({bool force = false}) async {
    if (!force && _lastBarbersFetch != null &&
        DateTime.now().difference(_lastBarbersFetch!) < _staleDuration &&
        _barbers.isNotEmpty) {
      return;
    }

    _barbersError = null;
    if (_barbers.isEmpty) _isLoadingBarbers = true;
    notifyListeners();

    try {
      final res = await _api.getBarbers();
      _barbers = (res.data['data'] as List)
          .map((b) => BarberModel.fromJson(b))
          .toList();
      _lastBarbersFetch = DateTime.now();
      _barbersError = null;
    } catch (e) {
      if (_barbers.isEmpty) {
        _barbersError = 'Gagal memuat barber. Periksa koneksi.';
      }
    } finally {
      _isLoadingBarbers = false;
      notifyListeners();
    }
  }

  // ── AVAILABLE SLOTS ────────────────────────────────────────

  Future<void> fetchAvailableSlots(int barberId, String date) async {
    _slotsError = null;
    _isLoadingSlots = true;
    notifyListeners();

    try {
      final res = await _api.getAvailableSlots(barberId, date);
      final data = res.data['data'];
      _isBarberUnavailable = data['is_unavailable'] == true;
      _unavailabilityLabel = data['unavailability_label'];
      _availableSlots = _isBarberUnavailable
          ? []
          : List<String>.from(data['available_slots']);
    } catch (_) {
      _availableSlots = [];
      _isBarberUnavailable = false;
      _unavailabilityLabel = null;
      _slotsError = 'Gagal memuat jadwal. Coba pilih tanggal lagi.';
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  // ── UNAVAILABLE DATES ──────────────────────────────────────

  Future<void> fetchUnavailableDates(
      int barberId, String from, String to) async {
    try {
      final res = await _api.getUnavailableDates(barberId, from, to);
      _unavailableDates = (res.data['data'] as List)
          .map((d) => BarberUnavailableDate.fromJson(d))
          .toList();
      notifyListeners();
    } catch (_) {
      _unavailableDates = [];
      notifyListeners();
    }
  }

  bool isDateUnavailable(String dateStr) {
    return _unavailableDates.any((d) => d.date == dateStr);
  }

  String? unavailableLabelForDate(String dateStr) {
    try {
      return _unavailableDates.firstWhere((d) => d.date == dateStr).label;
    } catch (_) {
      return null;
    }
  }

  // ── RESET ──────────────────────────────────────────────────

  void resetSlots() {
    _availableSlots = [];
    _isBarberUnavailable = false;
    _unavailabilityLabel = null;
    _slotsError = null;
    notifyListeners();
  }
}
