import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking_model.dart';
import '../screens/user/payment_screen.dart';
import '../utils/app_colors.dart';

Future<void> showBookingConfirmedDialog(
  BuildContext context,
  BookingModel booking,
) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.success),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Booking Dikonfirmasi!',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ]),
      content: Text(
        'Admin telah mengonfirmasi booking ${booking.bookingCode}. '
        'Silakan lakukan pembayaran untuk mengamankan jadwal.',
        style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Nanti',
              style: GoogleFonts.poppins(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(booking: booking),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          child: Text('Bayar Sekarang',
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
