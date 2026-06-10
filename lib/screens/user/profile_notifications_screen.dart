import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_colors.dart';

class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState extends State<ProfileNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifikasi')),
      body: Consumer<BookingProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          final items = _buildItems(provider.bookings);
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 56, color: AppColors.grey.withValues(alpha: 0.6)),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada notifikasi',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pembaruan booking dan pembayaran akan muncul di sini.',
                      style: GoogleFonts.poppins(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: provider.fetchMyBookings,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => items[i],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildItems(List<BookingModel> bookings) {
    final widgets = <Widget>[];
    for (final b in bookings) {
      if (b.isAwaitingAdmin) {
        widgets.add(_NotifTile(
          icon: Icons.hourglass_top,
          color: AppColors.warning,
          title: 'Menunggu konfirmasi',
          body: '${b.bookingCode} — ${b.servicesDisplay}',
          time: _formatDate(b.bookingDate),
        ));
      } else if (b.canPay) {
        widgets.add(_NotifTile(
          icon: Icons.payment,
          color: AppColors.secondary,
          title: 'Siap dibayar',
          body: '${b.bookingCode} — ${b.priceFormatted}',
          time: _formatDate(b.bookingDate),
        ));
      } else if (b.isCashlessPending) {
        widgets.add(_NotifTile(
          icon: Icons.storefront,
          color: AppColors.secondary,
          title: 'Bayar di tempat',
          body: '${b.bookingCode} — tunjukkan ke kasir',
          time: _formatDate(b.bookingDate),
        ));
      } else if (b.isPaid) {
        widgets.add(_NotifTile(
          icon: Icons.check_circle,
          color: AppColors.success,
          title: 'Pembayaran lunas',
          body: '${b.bookingCode} — ${b.servicesDisplay}',
          time: _formatDate(b.bookingDate),
        ));
      }
    }
    return widgets;
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;

  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    color: AppColors.lightGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
