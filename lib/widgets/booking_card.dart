// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../utils/app_colors.dart';
import 'booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const BookingCard({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    final paymentStatus = booking.payment?.status ?? '';
    final paymentColor = paymentStatus == 'paid'
        ? AppColors.success
        : paymentStatus == 'failed' || paymentStatus == 'expired'
            ? AppColors.error
            : AppColors.warning;
    final paymentLabel = booking.paymentStatusLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Kode + status
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(booking.bookingCode,
                  style: GoogleFonts.poppins(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              BookingStatusBadge(status: booking.status),
            ]),
            const Divider(color: AppColors.divider),

            // Nama layanan
            Text(booking.servicesDisplay,
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 6),

            // Barber
            Row(children: [
              const Icon(Icons.person, color: AppColors.grey, size: 14),
              const SizedBox(width: 4),
              Text(booking.barber?.name ?? '-',
                  style:
                      GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 2),

            // Tanggal & waktu — FIXED format
            Row(children: [
              const Icon(Icons.calendar_today, color: AppColors.grey, size: 14),
              const SizedBox(width: 4),
              Text(
                '${booking.bookingDateFormatted}  pukul ${booking.timeDisplay}',
                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 8),

            // Harga + status pembayaran
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Status pembayaran
              if (booking.payment != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: paymentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: paymentColor.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        paymentStatus == 'paid'
                            ? Icons.check_circle
                            : Icons.payment,
                        color: paymentColor,
                        size: 12),
                    const SizedBox(width: 4),
                    Text(paymentLabel,
                        style: GoogleFonts.poppins(
                            color: paymentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ]),
                )
              else
                const SizedBox(),

              // Harga
              Text(booking.priceFormatted,
                  style: GoogleFonts.poppins(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ]),
          ]),
        ),
      ),
    );
  }
}
