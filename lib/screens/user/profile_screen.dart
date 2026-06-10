// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/custom_text_field.dart';
import 'profile_notifications_screen.dart';
import 'profile_help_screen.dart';
import 'profile_about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await context.read<AuthProvider>().updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: AppColors.success,
      ));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? 'Batal' : 'Edit',
                style: GoogleFonts.poppins(color: AppColors.secondary)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          await context.read<AuthProvider>().refreshProfile();
        },
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Avatar
          Center(
              child: Stack(children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  gradient: AppColors.goldGradient, shape: BoxShape.circle),
              child: Center(
                  child: Text(
                user?.name[0].toUpperCase() ?? 'U',
                style: GoogleFonts.playfairDisplay(
                    color: AppColors.primary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              )),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: AppColors.secondary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      size: 14, color: AppColors.primary),
                ),
              ),
          ])),
          const SizedBox(height: 12),
          Text(user?.name ?? '',
              style: Theme.of(context).textTheme.headlineMedium),
          Text(user?.email ?? '',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (user?.role ?? '').toUpperCase(),
              style: GoogleFonts.poppins(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          // Form edit (hanya muncul saat mode edit)
          if (_isEditing) ...[
            _label('Nama Lengkap'),
            CustomTextField(
                controller: _nameCtrl,
                hintText: 'Nama kamu',
                prefixIcon: Icons.person_outlined),
            const SizedBox(height: 14),
            _label('Nomor HP'),
            CustomTextField(
                controller: _phoneCtrl,
                hintText: '08xxxxxxxxxx',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (_, auth, __) => GoldButton(
                onPressed: auth.isLoading ? null : _save,
                isLoading: auth.isLoading,
                label: 'SIMPAN PERUBAHAN',
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Menu navigasi
          _menuItem(Icons.history_outlined, 'Riwayat Booking',
              () => Navigator.pushNamed(context, AppRoutes.history)),
          _menuItem(
            Icons.notifications_outlined,
            'Notifikasi',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ProfileNotificationsScreen()),
            ),
          ),
          _menuItem(
            Icons.help_outline,
            'Bantuan',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileHelpScreen()),
            ),
          ),
          _menuItem(
            Icons.info_outline,
            'Tentang App',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileAboutScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _menuItem(Icons.logout, 'Keluar dari Akun', _logout,
              color: AppColors.error),
          const SizedBox(height: 20),
        ]),
      ),
    ));
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(t,
              style: GoogleFonts.poppins(
                  color: AppColors.lightGrey, fontSize: 13)),
        ),
      );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.lightGrey, size: 20),
        title: Text(label,
            style: GoogleFonts.poppins(
                color: color ?? AppColors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: AppColors.grey, size: 13),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
