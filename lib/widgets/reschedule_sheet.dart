// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/barber_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/gold_button.dart';

void showRescheduleSheet(
  BuildContext context, {
  required BookingModel booking,
  required VoidCallback onDone,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _RescheduleSheet(booking: booking, onDone: onDone),
  );
}

class _RescheduleSheet extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onDone;

  const _RescheduleSheet({required this.booking, required this.onDone});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    try {
      _selectedDate = DateTime.parse(widget.booking.bookingDate);
      _selectedTime = widget.booking.timeDisplay;
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final barberId = widget.booking.barber?.id;
      if (barberId == null) return;
      final from = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final to = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 13)));
      context.read<BarberProvider>().fetchUnavailableDates(barberId, from, to);
      if (_selectedDate != null) {
        context.read<BarberProvider>().fetchAvailableSlots(
            barberId, DateFormat('yyyy-MM-dd').format(_selectedDate!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final barberProvider = context.watch<BarberProvider>();
    final barberId = widget.booking.barber?.id;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ubah Jadwal',
                    style: Theme.of(context).textTheme.headlineMedium),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              'Barber: ${widget.booking.barber?.name ?? '-'}',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
            ),
            if (widget.booking.status == 'confirmed') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Text(
                  'Jadwal yang sudah dikonfirmasi admin akan kembali menunggu konfirmasi setelah diubah.',
                  style: GoogleFonts.poppins(
                      color: AppColors.warning, fontSize: 11),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Pilih Tanggal',
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 78,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (_, i) {
                  final date = DateTime.now().add(Duration(days: i));
                  final dateStr = DateFormat('yyyy-MM-dd').format(date);
                  final isUnavailable =
                      barberProvider.isDateUnavailable(dateStr);
                  final isSelected = _selectedDate != null &&
                      DateFormat('yyyy-MM-dd').format(_selectedDate!) ==
                          dateStr;
                  return GestureDetector(
                    onTap: isUnavailable || barberId == null
                        ? null
                        : () {
                            setState(() {
                              _selectedDate = date;
                              _selectedTime = null;
                            });
                            barberProvider.fetchAvailableSlots(barberId, dateStr);
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
                              : AppColors.divider,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('EEE').format(date).toUpperCase(),
                              style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey,
                                  fontSize: 9)),
                          Text(DateFormat('d').format(date),
                              style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Pilih Waktu',
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (_selectedDate == null)
              Text('Pilih tanggal dulu',
                  style: GoogleFonts.poppins(
                      color: AppColors.grey, fontSize: 12))
            else if (bookingProvider.isLoading)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary))
            else if (barberProvider.isBarberUnavailable)
              Text('Barber tidak tersedia pada tanggal ini',
                  style: GoogleFonts.poppins(
                      color: AppColors.error, fontSize: 12))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.timeSlots.map((slot) {
                  final isAvail = barberProvider.availableSlots.contains(slot);
                  final isSelected = _selectedTime == slot;
                  return GestureDetector(
                    onTap: isAvail ? () => setState(() => _selectedTime = slot) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.goldGradient : null,
                        color: isSelected
                            ? null
                            : (isAvail
                                ? AppColors.surfaceLight
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(slot,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? AppColors.primary
                                : (isAvail
                                    ? AppColors.white
                                    : AppColors.grey),
                            fontSize: 12,
                            decoration:
                                isAvail ? null : TextDecoration.lineThrough,
                          )),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            GoldButton(
              onPressed: bookingProvider.isLoading ||
                      _selectedDate == null ||
                      _selectedTime == null
                  ? null
                  : _save,
              isLoading: bookingProvider.isLoading,
              label: 'SIMPAN JADWAL BARU',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final result = await context.read<BookingProvider>().rescheduleBooking(
          bookingId: widget.booking.id,
          bookingDate: dateStr,
          bookingTime: _selectedTime!,
        );

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context);
      widget.onDone();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Jadwal berhasil diubah'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            context.read<BookingProvider>().error ?? 'Gagal mengubah jadwal'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
