import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/service_provider.dart';
import '../providers/barber_provider.dart';
import '../providers/admin_booking_provider.dart';
import '../providers/admin_transaction_provider.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Tunggu animasi dulu
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.tryAutoLogin();
    if (!mounted) return;

    if (!loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    // Validasi token dengan panggil profile API (timeout 10 detik)
    try {
      await ApiService().getProfile().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Koneksi timeout'),
      );
      // Token valid → pre-fetch data sebelum navigasi
      if (!mounted) return;
      _prefetchData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        auth.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home,
      );
    } on TimeoutException catch (_) {
      // Timeout → logout paksa
      if (!mounted) return;
      await auth.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (_) {
      // Token tidak valid atau error lain → logout paksa
      await auth.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  /// Pre-fetch data di background agar langsung siap ketika screen terbuka.
  void _prefetchData() {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    if (isAdmin) {
      context.read<AdminBookingProvider>().fetch();
      context.read<AdminTransactionProvider>().fetchTransactions();
    } else {
      context.read<BookingProvider>().fetchMyBookings();
      context.read<ServiceProvider>().fetchServices();
      context.read<BarberProvider>().fetchBarbers();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.secondary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ARFAN',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    letterSpacing: 8,
                  ),
                ),
                Text(
                  'B A R B E R S H O P',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.lightGrey,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    // ignore: deprecated_member_use
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary.withOpacity(0.8)),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
