import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/service_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/shimmer_loading.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});
  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  Future<void> _fetch() async {
    await context.read<ServiceProvider>().fetchServices(force: true);
  }

  // Buka form tambah/edit layanan
  void _openForm({Map? service}) {
    final nameCtrl  = TextEditingController(text: service?['name']);
    final priceCtrl = TextEditingController(text: service?['price']?.toString());
    final durCtrl   = TextEditingController(text: service?['duration']?.toString());
    final descCtrl  = TextEditingController(text: service?['description']);
    final formKey   = GlobalKey<FormState>();
    bool  saving    = false;

    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(service == null ? 'Tambah Layanan' : 'Edit Layanan',
                    style: Theme.of(ctx).textTheme.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 16),

                Text('Nama Layanan', style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 12)),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: nameCtrl, hintText: 'Contoh: Regular Haircut',
                  prefixIcon: Icons.content_cut,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Harga (Rp)', style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 12)),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: priceCtrl, hintText: '50000',
                      prefixIcon: Icons.attach_money, keyboardType: TextInputType.number,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Durasi (menit)', style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 12)),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: durCtrl, hintText: '30',
                      prefixIcon: Icons.timer_outlined, keyboardType: TextInputType.number,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                  ])),
                ]),
                const SizedBox(height: 12),

                Text('Deskripsi (opsional)', style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 12)),
                const SizedBox(height: 6),
                CustomTextField(
                  controller: descCtrl, hintText: 'Deskripsi layanan...',
                  prefixIcon: Icons.description_outlined),
                const SizedBox(height: 20),

                GoldButton(
                  onPressed: saving ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setModal(() => saving = true);
                    try {
                      final data = {
                        'name': nameCtrl.text, 'price': priceCtrl.text,
                        'duration': durCtrl.text, 'description': descCtrl.text,
                      };
                      if (service == null) {
                        await ApiService().createService(data);
                      } else {
                        await ApiService().updateService(service['id'], data);
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) context.read<ServiceProvider>().fetchServices(force: true);
                    } catch (_) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('Gagal menyimpan'), backgroundColor: AppColors.error));
                    }
                    setModal(() => saving = false);
                  },
                  isLoading: saving,
                  label: service == null ? 'SIMPAN LAYANAN' : 'PERBARUI LAYANAN',
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:   const Text('Hapus Layanan'),
        content: const Text('Yakin ingin menghapus layanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed:  () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) { await ApiService().deleteService(id); if (mounted) context.read<ServiceProvider>().fetchServices(force: true); }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola Layanan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:       () => _openForm(),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        icon:  const Icon(Icons.add),
        label: Text('Tambah', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ServiceProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading && provider.services.isEmpty) {
            return const ShimmerList(
              itemBuilder: ShimmerAdminCard.new,
              count: 5,
            );
          }
          if (provider.error != null && provider.services.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text(provider.error!, textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh, color: AppColors.secondary),
                      label: Text('Coba Lagi',
                        style: GoogleFonts.poppins(color: AppColors.secondary)),
                    ),
                  ],
                ),
              ),
            );
          }
          final services = provider.services;
          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: _fetch,
            child: services.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(32),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.design_services_outlined, color: AppColors.grey, size: 56),
                            SizedBox(height: 12),
                            Text('Belum ada layanan',
                              style: TextStyle(color: AppColors.grey, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('Tekan tombol Tambah untuk menambahkan layanan',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.content_cut, color: AppColors.primary, size: 20),
                    ),
                    title: Text(s.name,
                      style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${s.priceFormatted}  •  ${s.duration} menit',
                      style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
                    trailing: PopupMenuButton(
                      color: AppColors.surfaceLight,
                      icon: const Icon(Icons.more_vert, color: AppColors.grey),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit', style: GoogleFonts.poppins(color: AppColors.white))),
                        PopupMenuItem(value: 'delete', child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.error))),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') _openForm(service: {'id': s.id, 'name': s.name, 'price': s.price.toString(), 'duration': s.duration.toString(), 'description': s.description});
                        if (val == 'delete') _delete(s.id);
                      },
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
