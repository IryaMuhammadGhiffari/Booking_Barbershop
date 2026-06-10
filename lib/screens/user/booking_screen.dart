// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../models/barber_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/barber_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/gold_button.dart';
import 'booking_submitted_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;

  final List<ServiceModel> _selectedServices = [];
  BarberModel? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = context.read<ServiceProvider>();
    final b = context.read<BarberProvider>();
    if (s.services.isEmpty) s.fetchServices();
    if (b.barbers.isEmpty) b.fetchBarbers();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _selectedServices.isEmpty) {
      _showSnack('Pilih minimal satu layanan');
      return;
    }
    if (_step == 1 && _selectedBarber == null) {
      _showSnack('Pilih barber terlebih dahulu');
      return;
    }
    if (_step == 2 && (_selectedDate == null || _selectedTime == null)) {
      _showSnack('Pilih tanggal dan waktu terlebih dahulu');
      return;
    }
    if (_step == 1 && _selectedBarber != null) {
      final from = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final to = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 13)));
      context
          .read<BarberProvider>()
          .fetchUnavailableDates(_selectedBarber!.id, from, to);
    }
    setState(() => _step++);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  Future<void> _confirmBooking() async {
    final booking = context.read<BookingProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final result = await booking.createBooking(
      barberId: _selectedBarber!.id,
      serviceIds: _selectedServices.map((s) => s.id).toList(),
      bookingDate: dateStr,
      bookingTime: _selectedTime!,
      notes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => BookingSubmittedScreen(booking: result)),
      );
    } else {
      _showSnack(booking.error ?? 'Gagal membuat booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () =>
              _step == 0 ? Navigator.pop(context) : setState(() => _step--),
        ),
      ),
      body: Column(
        children: [
          _buildStepBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepBar() {
    final labels = ['Layanan', 'Barber', 'Jadwal', 'Konfirmasi'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(labels.length, (i) {
          final done = i < _step;
          final current = i == _step;
          return Expanded(
            child: Row(
              children: [
                Column(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: done || current ? AppColors.goldGradient : null,
                      color: done || current ? null : AppColors.surfaceLight,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check,
                              size: 14, color: AppColors.primary)
                          : Text('${i + 1}',
                              style: GoogleFonts.poppins(
                                  color: current
                                      ? AppColors.primary
                                      : AppColors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i],
                      style: GoogleFonts.poppins(
                        color: done || current
                            ? AppColors.secondary
                            : AppColors.grey,
                        fontSize: 9,
                      )),
                ]),
                if (i < labels.length - 1)
                  Expanded(
                      child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < _step ? AppColors.secondary : AppColors.divider,
                  )),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:
        return _StepService(
            selected: _selectedServices,
            onToggle: (s) => setState(() {
              final idx = _selectedServices.indexWhere((x) => x.id == s.id);
              if (idx >= 0) {
                _selectedServices.removeAt(idx);
              } else {
                _selectedServices.add(s);
              }
            }));
      case 1:
        return _StepBarber(
            selected: _selectedBarber,
            onSelect: (b) {
              setState(() => _selectedBarber = b);
              final from = DateFormat('yyyy-MM-dd').format(DateTime.now());
              final to = DateFormat('yyyy-MM-dd')
                  .format(DateTime.now().add(const Duration(days: 13)));
              context
                  .read<BarberProvider>()
                  .fetchUnavailableDates(b.id, from, to);
            });
      case 2:
        return _StepSchedule(
          selectedBarber: _selectedBarber!,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          notesCtrl: _notesCtrl,
          onDateSelected: (d) => setState(() {
            _selectedDate = d;
            _selectedTime = null;
            context.read<BarberProvider>().resetSlots();
          }),
          onTimeSelected: (t) => setState(() => _selectedTime = t),
        );
      case 3:
        return _StepConfirm(
          services: _selectedServices,
          barber: _selectedBarber!,
          date: _selectedDate!,
          time: _selectedTime!,
          notes: _notesCtrl.text,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar() {
    final loading = context.watch<BookingProvider>().isLoading;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: GoldButton(
        onPressed: loading ? null : (_step == 3 ? _confirmBooking : _next),
        isLoading: loading,
        label: _step == 3 ? 'KIRIM BOOKING' : 'SELANJUTNYA',
      ),
    );
  }
}

// Step 1 — Pilih Layanan (pakai ServiceProvider)
class _StepService extends StatelessWidget {
  final List<ServiceModel> selected;
  final ValueChanged<ServiceModel> onToggle;
  const _StepService({required this.selected, required this.onToggle});

  double get _totalPrice =>
      selected.fold(0.0, (sum, s) => sum + s.price);

  String get _totalPriceFormatted {
    final formatted = _totalPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<ServiceProvider>().services;
    if (services.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.secondary));
    }
    return Column(
      children: [
        if (selected.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${selected.length} layanan dipilih',
                    style: GoogleFonts.poppins(
                        color: AppColors.white, fontSize: 13)),
                Text(_totalPriceFormatted,
                    style: GoogleFonts.poppins(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: services.length,
            itemBuilder: (_, i) {
              final s = services[i];
              final isActive = selected.any((x) => x.id == s.id);
              return GestureDetector(
                onTap: () => onToggle(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive ? AppColors.secondary : AppColors.divider,
                      width: isActive ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.goldGradient : null,
                        color: isActive ? null : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(Icons.content_cut,
                          color: isActive ? AppColors.primary : AppColors.grey,
                          size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(s.name,
                              style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text('${s.duration} menit',
                              style: GoogleFonts.poppins(
                                  color: AppColors.grey, fontSize: 12)),
                        ])),
                    Text(s.priceFormatted,
                        style: GoogleFonts.poppins(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(width: 8),
                    Icon(
                      isActive
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isActive ? AppColors.secondary : AppColors.grey,
                      size: 22,
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Step 2 — Pilih Barber (pakai BarberProvider)
class _StepBarber extends StatelessWidget {
  final BarberModel? selected;
  final ValueChanged<BarberModel> onSelect;
  const _StepBarber({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final barbers = context.watch<BarberProvider>().barbers;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: barbers.length,
      itemBuilder: (_, i) {
        final b = barbers[i];
        final isActive = selected?.id == b.id;
        return GestureDetector(
          onTap: () => onSelect(b),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.secondary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.secondary : AppColors.divider,
                width: isActive ? 1.5 : 0.5,
              ),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    isActive ? AppColors.secondary : AppColors.surfaceLight,
                child: Text(b.name[0],
                    style: GoogleFonts.playfairDisplay(
                        color: isActive ? AppColors.primary : AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(b.name,
                        style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(b.specialty ?? '',
                        style: GoogleFonts.poppins(
                            color: AppColors.grey, fontSize: 12)),
                    Row(children: [
                      const Icon(Icons.star,
                          color: AppColors.secondary, size: 13),
                      const SizedBox(width: 3),
                      Text(b.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('${b.experienceYears} thn',
                          style: GoogleFonts.poppins(
                              color: AppColors.grey, fontSize: 11)),
                    ]),
                  ])),
              if (isActive)
                const Icon(Icons.check_circle,
                    color: AppColors.secondary, size: 18),
            ]),
          ),
        );
      },
    );
  }
}

// Step 3 — Pilih Jadwal (pakai BarberProvider untuk slot/date)
class _StepSchedule extends StatelessWidget {
  final BarberModel selectedBarber;
  final DateTime? selectedDate;
  final String? selectedTime;
  final TextEditingController notesCtrl;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onTimeSelected;

  const _StepSchedule({
    required this.selectedBarber,
    required this.selectedDate,
    required this.selectedTime,
    required this.notesCtrl,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final barber = context.watch<BarberProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pilih Tanggal', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (_, i) {
              final date = DateTime.now().add(Duration(days: i));
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final isUnavailable = barber.isDateUnavailable(dateStr);
              final unavailableLabel = barber.unavailableLabelForDate(dateStr);
              final isSelected = selectedDate != null &&
                  DateFormat('yyyy-MM-dd').format(selectedDate!) == dateStr;
              return GestureDetector(
                onTap: isUnavailable
                    ? null
                    : () {
                        onDateSelected(date);
                        barber.fetchAvailableSlots(selectedBarber.id, dateStr);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        width: 58,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.goldGradient : null,
                          color: isSelected
                              ? null
                              : (isUnavailable
                                  ? AppColors.surfaceLight.withOpacity(0.5)
                                  : AppColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : (isUnavailable
                                      ? AppColors.error.withOpacity(0.4)
                                      : AppColors.divider)),
                        ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(date).toUpperCase(),
                            style: GoogleFonts.poppins(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isUnavailable
                                        ? AppColors.grey
                                        : AppColors.grey),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                        Text(DateFormat('d').format(date),
                            style: GoogleFonts.poppins(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isUnavailable
                                        ? AppColors.grey
                                        : AppColors.white),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: isUnavailable
                                    ? TextDecoration.lineThrough
                                    : null)),
                        Text(
                            isUnavailable
                                ? (unavailableLabel ?? 'Off')
                                : DateFormat('MMM').format(date),
                            style: GoogleFonts.poppins(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isUnavailable
                                        ? AppColors.error
                                        : AppColors.grey),
                                fontSize: 8),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        Text('Pilih Waktu', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (selectedDate == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text('Pilih tanggal dulu',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.grey)),
          )
        else if (barber.isLoadingSlots)
          const Center(
              child: CircularProgressIndicator(color: AppColors.secondary))
        else if (barber.slotsError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Text(barber.slotsError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontSize: 13)),
          )
        else if (barber.isBarberUnavailable)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.event_busy, color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Barber tidak tersedia (${barber.unavailabilityLabel ?? 'Libur'}). Pilih tanggal lain.',
                  style: GoogleFonts.poppins(
                      color: AppColors.error, fontSize: 13),
                ),
              ),
            ]),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.timeSlots.map((slot) {
              final isAvail = barber.availableSlots.contains(slot);
              final isSelected = selectedTime == slot;
              return GestureDetector(
                onTap: isAvail ? () => onTimeSelected(slot) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.goldGradient : null,
                    color: isSelected
                        ? null
                        : (isAvail
                            ? AppColors.surface
                            : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : (isAvail
                                ? AppColors.divider
                                : Colors.transparent)),
                  ),
                  child: Text(slot,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? AppColors.primary
                            : (isAvail ? AppColors.white : AppColors.grey),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        decoration: isAvail ? null : TextDecoration.lineThrough,
                      )),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        Text('Catatan (opsional)',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: notesCtrl,
          maxLines: 3,
          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Contoh: potong pendek di samping...',
          ),
        ),
      ],
    );
  }
}

// Step 4 — Konfirmasi (tidak berubah)
class _StepConfirm extends StatelessWidget {
  final List<ServiceModel> services;
  final BarberModel barber;
  final DateTime date;
  final String time;
  final String notes;
  const _StepConfirm({
    required this.services,
    required this.barber,
    required this.date,
    required this.time,
    required this.notes,
  });

  double get _totalPrice =>
      services.fold(0.0, (sum, s) => sum + s.price);

  String get _totalPriceFormatted {
    final formatted = _totalPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  int get _totalDuration =>
      services.fold(0, (sum, s) => sum + s.duration);

  Widget _row(BuildContext ctx, String label, String value, {String? sub}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style:
                    GoogleFonts.poppins(color: AppColors.grey, fontSize: 11)),
            Text(value,
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            if (sub != null)
              Text(sub,
                  style: GoogleFonts.poppins(
                      color: AppColors.secondary, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(date);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ringkasan Booking',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Layanan',
                  style: GoogleFonts.poppins(
                      color: AppColors.grey, fontSize: 11)),
              const SizedBox(height: 6),
              ...services.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.name,
                            style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text(s.priceFormatted,
                            style: GoogleFonts.poppins(
                                color: AppColors.secondary, fontSize: 12)),
                      ],
                    ),
                  )),
              Text('Estimasi $_totalDuration menit',
                  style: GoogleFonts.poppins(
                      color: AppColors.grey, fontSize: 11)),
            ],
          ),
        ),
        _row(context, 'Barber', barber.name, sub: barber.specialty),
        _row(context, 'Tanggal', dateStr, sub: 'Pukul $time WIB'),
        if (notes.isNotEmpty) _row(context, 'Catatan', notes),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Bayar',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              Text(_totalPriceFormatted,
                  style: GoogleFonts.playfairDisplay(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ],
          ),
        ),
      ],
    );
  }
}
