import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      name:                 _nameCtrl.text.trim(),
      email:                _emailCtrl.text.trim(),
      phone:                _phoneCtrl.text.trim(),
      password:             _passCtrl.text,
      passwordConfirmation: _confirmCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(auth.errorMessage ?? 'Registrasi gagal'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 13)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Akun', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                Text('Isi data di bawah untuk mendaftar', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),

                _label('Nama Lengkap'),
                CustomTextField(
                  controller: _nameCtrl, hintText: 'Nama kamu', prefixIcon: Icons.person_outlined,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                _label('Email'),
                CustomTextField(
                  controller: _emailCtrl, hintText: 'email@kamu.com',
                  prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email wajib diisi';
                    if (!v!.contains('@'))  return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Nomor HP'),
                CustomTextField(
                  controller: _phoneCtrl, hintText: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Nomor HP wajib diisi';
                    if (v!.length < 10)     return 'Nomor HP tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Password'),
                CustomTextField(
                  controller: _passCtrl, hintText: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outlined, obscureText: _obscure1,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Password wajib diisi';
                    if (v!.length < 6)      return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Konfirmasi Password'),
                CustomTextField(
                  controller: _confirmCtrl, hintText: 'Ulangi password',
                  prefixIcon: Icons.lock_outlined, obscureText: _obscure2,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                  validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
                ),
                const SizedBox(height: 36),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => GoldButton(
                    onPressed: auth.isLoading ? null : _register,
                    isLoading: auth.isLoading,
                    label:     'DAFTAR',
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: Theme.of(context).textTheme.bodyLarge),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Masuk', style: GoogleFonts.poppins(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
