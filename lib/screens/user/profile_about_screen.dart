import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';

class ProfileAboutScreen extends StatelessWidget {
  const ProfileAboutScreen({super.key});

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tentang App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Arfan Barbershop',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Versi 1.0.0',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Text(
              'Aplikasi pemesanan layanan barbershop. Booking online, konfirmasi jadwal, dan pembayaran dalam satu tempat.',
              style: GoogleFonts.poppins(
                color: AppColors.lightGrey,
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const _InfoCard(
              icon: Icons.location_on_outlined,
              title: 'Alamat',
              value: 'Arfan Barbershop',
            ),
            const _InfoCard(
              icon: Icons.access_time,
              title: 'Jam Operasional',
              value: 'Senin – Minggu\n10:00 – 21:00 WIB',
            ),
            _InfoCard(
              icon: Icons.phone_outlined,
              title: 'Kontak',
              value: '0815-4650-6448',
              onTap: () => _call('081546506448'),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 Arfan Barbershop',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.secondary, size: 22),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.grey,
            fontSize: 11,
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.grey)
            : null,
      ),
    );
  }
}
