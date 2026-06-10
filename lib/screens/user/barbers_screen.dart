// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/barber_provider.dart';
import '../../models/barber_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class BarbersScreen extends StatefulWidget {
  const BarbersScreen({super.key});
  @override
  State<BarbersScreen> createState() => _BarbersScreenState();
}

class _BarbersScreenState extends State<BarbersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BarberProvider>().fetchBarbers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tim Barber Kami')),
      body: Consumer<BarberProvider>(
        builder: (_, barber, __) {
          if (barber.isLoadingBarbers && barber.barbers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }
          if (barber.barbers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.content_cut, color: AppColors.grey, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      barber.barbersError ?? 'Belum ada barber tersedia',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => context.read<BarberProvider>().fetchBarbers(force: true),
                      icon: const Icon(Icons.refresh, color: AppColors.secondary),
                      label: Text('Muat Ulang',
                        style: GoogleFonts.poppins(color: AppColors.secondary)),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color:     AppColors.secondary,
            onRefresh: () => context.read<BarberProvider>().fetchBarbers(force: true),
            child: ListView.builder(
              padding:     const EdgeInsets.all(16),
              itemCount:   barber.barbers.length,
              itemBuilder: (_, i) => _BarberCard(barber: barber.barbers[i]),
            ),
          );
        },
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  final BarberModel barber;
  const _BarberCard({required this.barber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape:    BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color:      AppColors.secondary.withOpacity(0.3),
                      blurRadius: 16,
                    )],
                  ),
                  child: Center(
                    child: Text(barber.name[0],
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(barber.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(barber.specialty ?? '',
                        style: GoogleFonts.poppins(color: AppColors.secondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(children: [
                        ...List.generate(5, (i) => Icon(
                          i < barber.rating.round() ? Icons.star : Icons.star_border,
                          color: AppColors.secondary, size: 14,
                        )),
                        const SizedBox(width: 6),
                        Text(barber.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            if (barber.bio != null && barber.bio!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(barber.bio!,
                style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 13, height: 1.6)),
            ],
            const SizedBox(height: 14),
            Row(children: [
              _Chip(icon: Icons.work_outline, label: '${barber.experienceYears} Tahun Pengalaman'),
              const SizedBox(width: 8),
              if (barber.services != null && barber.services!.isNotEmpty)
                _Chip(icon: Icons.content_cut, label: '${barber.services!.length} Layanan'),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:     AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed:  () => Navigator.pushNamed(context, AppRoutes.booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor:     Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Booking dengan ${barber.name.split(' ').first}',
                    style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.grey, size: 13),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 11)),
      ]),
    );
  }
}
