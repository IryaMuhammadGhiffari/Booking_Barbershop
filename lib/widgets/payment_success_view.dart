// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/gold_button.dart';

class PaymentSuccessView extends StatelessWidget {
  final String bookingCode;
  final VoidCallback onDone;

  const PaymentSuccessView({
    super.key,
    required this.bookingCode,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 52),
            ),
            const SizedBox(height: 24),
            Text(
              'Pembayaran Berhasil!',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              bookingCode,
              style: GoogleFonts.poppins(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pembayaran tercatat. Sampai jumpa di Arfan Barbershop!',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GoldButton(
              onPressed: onDone,
              label: 'SELESAI',
              icon: Icons.check,
            ),
          ]),
        ),
      ),
    );
  }
}
