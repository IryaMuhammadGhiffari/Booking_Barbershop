import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Layanan Kami')),
      body: Consumer<ServiceProvider>(
        builder: (_, svc, __) {
          if (svc.isLoading && svc.services.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }
          if (svc.services.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.content_cut, color: AppColors.grey, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    svc.error ?? 'Belum ada layanan',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => context.read<ServiceProvider>().fetchServices(force: true),
                    icon: const Icon(Icons.refresh, color: AppColors.secondary),
                    label: Text('Muat Ulang',
                      style: GoogleFonts.poppins(color: AppColors.secondary)),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color:     AppColors.secondary,
            onRefresh: () => context.read<ServiceProvider>().fetchServices(force: true),
            child: ListView.builder(
              padding:     const EdgeInsets.all(16),
              itemCount:   svc.services.length,
              itemBuilder: (_, i) {
                final s = svc.services[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:        AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:       Border.all(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            gradient:     AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.content_cut, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name,
                                style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                              if (s.description != null && s.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(s.description!,
                                    style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.timer_outlined, color: AppColors.grey, size: 14),
                                const SizedBox(width: 4),
                                Text('${s.duration} menit',
                                  style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(s.priceFormatted,
                              style: GoogleFonts.poppins(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient:     AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Booking',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
