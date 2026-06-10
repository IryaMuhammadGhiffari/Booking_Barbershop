import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_barber_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/extensions.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/shimmer_loading.dart';

class AdminBarbersScreen extends StatefulWidget {
  const AdminBarbersScreen({super.key});
  @override
  State<AdminBarbersScreen> createState() => _AdminBarbersScreenState();
}

class _AdminBarbersScreenState extends State<AdminBarbersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBarberProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminBarberProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Kelola Barber')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:       () => _openForm(context),
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.primary,
            icon:  const Icon(Icons.add),
            label: Text('Tambah', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
          body: _buildBody(context, prov),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminBarberProvider prov) {
    if (prov.isLoading && prov.barbers.isEmpty) {
      return const ShimmerList(
        itemBuilder: ShimmerAdminCard.new,
        count: 5,
      );
    }

    return RefreshIndicator(
      color:     AppColors.secondary,
      onRefresh: prov.fetch,
      child: prov.error != null && prov.barbers.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(32),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text(prov.error!, textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => prov.fetch(),
                        icon: const Icon(Icons.refresh, color: AppColors.secondary),
                        label: Text('Coba Lagi',
                          style: GoogleFonts.poppins(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : prov.barbers.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(32),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.content_cut, color: AppColors.grey, size: 48),
                          SizedBox(height: 12),
                          Text('Belum ada barber',
                            style: TextStyle(color: AppColors.grey, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Tekan tombol Tambah untuk menambahkan barber',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
        padding:     const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount:   prov.barbers.length,
        itemBuilder: (_, i) {
          final b = prov.barbers[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondary,
                child: Text(b['name'][0], style: GoogleFonts.playfairDisplay(
                  color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              title: Text(b['name'], style: GoogleFonts.poppins(
                color: AppColors.white, fontWeight: FontWeight.w600)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b['specialty'] ?? '', style: GoogleFonts.poppins(
                  color: AppColors.secondary, fontSize: 12)),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.secondary, size: 12),
                  const SizedBox(width: 3),
                  Text('${b['rating']}  •  ${b['experience_years']} thn',
                    style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 11)),
                ]),
              ]),
              trailing: PopupMenuButton(
                color: AppColors.surfaceLight,
                icon:  const Icon(Icons.more_vert, color: AppColors.grey),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'off', child: Text('Jadwal Off',
                    style: GoogleFonts.poppins(color: AppColors.white))),
                  PopupMenuItem(value: 'edit', child: Text('Edit',
                    style: GoogleFonts.poppins(color: AppColors.white))),
                ],
                onSelected: (val) {
                  if (val == 'edit') _openForm(context, barber: b, onSaved: prov.fetch);
                  if (val == 'off') _openUnavailability(context, b);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Form Tambah / Edit Barber
  // ───────────────────────────────────────────────
  void _openForm(BuildContext context, {Map? barber, VoidCallback? onSaved}) {
    final prov = context.read<AdminBarberProvider>();
    final nameCtrl = TextEditingController(text: barber?['name']);
    final specCtrl = TextEditingController(text: barber?['specialty']);
    final bioCtrl  = TextEditingController(text: barber?['bio']);
    final expCtrl  = TextEditingController(text: barber?['experience_years']?.toString());
    final formKey  = GlobalKey<FormState>();
    bool  saving   = false;

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
                  Text(barber == null ? 'Tambah Barber' : 'Edit Barber',
                    style: Theme.of(ctx).textTheme.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 16),

                _lbl('Nama Barber'),
                CustomTextField(
                  controller: nameCtrl, hintText: 'Nama lengkap barber',
                  prefixIcon: Icons.person_outlined,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),

                _lbl('Spesialisasi'),
                CustomTextField(
                  controller: specCtrl, hintText: 'Contoh: Fade & Classic Cut',
                  prefixIcon: Icons.star_outline,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),

                _lbl('Pengalaman (tahun)'),
                CustomTextField(
                  controller: expCtrl, hintText: '3',
                  prefixIcon: Icons.work_outline, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                _lbl('Bio (opsional)'),
                CustomTextField(
                  controller: bioCtrl, hintText: 'Deskripsi singkat barber...',
                  prefixIcon: Icons.info_outline),
                const SizedBox(height: 20),

                GoldButton(
                  onPressed: saving ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setModal(() => saving = true);
                    final data = {
                      'name': nameCtrl.text, 'specialty': specCtrl.text,
                      'bio':  bioCtrl.text,  'experience_years': expCtrl.text,
                    };
                    bool ok;
                    if (barber == null) {
                      ok = await prov.create(data);
                    } else {
                      ok = await prov.update(barber['id'], data);
                    }
                    if (!ctx.mounted) return;
                    if (ok) {
                      Navigator.pop(ctx);
                      prov.fetch();
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(prov.error ?? 'Gagal menyimpan'),
                        backgroundColor: AppColors.error));
                    }
                    setModal(() => saving = false);
                  },
                  isLoading: saving,
                  label: barber == null ? 'SIMPAN BARBER' : 'PERBARUI BARBER',
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Jadwal Off
  // ───────────────────────────────────────────────
  void _openUnavailability(BuildContext context, Map barber) {
    final api = ApiService();
    List items = [];
    bool loading = true;
    bool saving = false;
    DateTime selectedDate = DateTime.now();
    String selectedReason = 'sick';
    final notesCtrl = TextEditingController();

    const reasonLabels = {
      'sick': 'Sakit',
      'leave': 'Izin',
      'off': 'Libur / Tidak Masuk',
    };

    String parseApiError(dynamic e) {
      if (e is DioException) {
        final msg = e.response?.data?['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (e.response?.statusCode == 422) {
          return 'Tanggal sudah ditandai off atau data tidak valid';
        }
      }
      return 'Gagal menyimpan jadwal off';
    }

    bool isDateAlreadyOff(String dateStr) {
      return items.any((item) => (item['date'] as String?)?.normalizeDate == dateStr);
    }

    Future<void> loadItems(StateSetter setModal) async {
      setModal(() => loading = true);
      try {
        final res = await api.getBarberUnavailabilities(barber['id']);
        items = res.data['data'] ?? [];
      } catch (_) {
        items = [];
      }
      setModal(() => loading = false);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          if (loading && items.isEmpty) loadItems(setModal);

          final selectedDateStr = selectedDate.toIso8601String().substring(0, 10);
          final alreadyOff = isDateAlreadyOff(selectedDateStr);

          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Jadwal Off — ${barber['name']}',
                          style: Theme.of(ctx).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    'Nonaktifkan barber pada tanggal tertentu (sakit, izin, atau libur)',
                    style: GoogleFonts.poppins(
                      color: AppColors.grey, fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (alreadyOff)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tanggal ini sudah off. Simpan lagi untuk perbarui alasan/catatan.',
                            style: GoogleFonts.poppins(color: AppColors.warning, fontSize: 11),
                          ),
                        ),
                      ]),
                    ),

                  _lbl('Tanggal'),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setModal(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.grey, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate.toIso8601String().substring(0, 10).formattedDateFull,
                            style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _lbl('Alasan'),
                  Wrap(
                    spacing: 8,
                    children: reasonLabels.entries.map((e) {
                      final active = selectedReason == e.key;
                      return ChoiceChip(
                        label: Text(e.value, style: GoogleFonts.poppins(fontSize: 11)),
                        selected: active,
                        selectedColor: AppColors.secondary.withOpacity(0.3),
                        backgroundColor: AppColors.surfaceLight,
                        labelStyle: TextStyle(
                          color: active ? AppColors.secondary : AppColors.grey,
                        ),
                        onSelected: (_) => setModal(() => selectedReason = e.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  _lbl('Catatan (opsional)'),
                  CustomTextField(
                    controller: notesCtrl,
                    hintText: 'Contoh: izin keluarga...',
                    prefixIcon: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 16),

                  GoldButton(
                    onPressed: saving ? null : () async {
                      setModal(() => saving = true);
                      try {
                        await api.createBarberUnavailability(
                          barber['id'],
                          {
                            'date': selectedDate.toIso8601String().substring(0, 10),
                            'reason': selectedReason,
                            if (notesCtrl.text.isNotEmpty) 'notes': notesCtrl.text,
                          },
                        );
                        notesCtrl.clear();
                        await loadItems(setModal);
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(alreadyOff
                              ? 'Jadwal off berhasil diperbarui'
                              : 'Jadwal off berhasil ditambahkan'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(parseApiError(e)), backgroundColor: AppColors.error),
                        );
                      }
                      setModal(() => saving = false);
                    },
                    isLoading: saving,
                    label: alreadyOff ? 'PERBARUI JADWAL OFF' : 'TAMBAH JADWAL OFF',
                  ),
                  const SizedBox(height: 20),

                  Text('Jadwal Off Mendatang',
                    style: GoogleFonts.poppins(
                      color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),

                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                    )
                  else if (items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Belum ada jadwal off',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13)),
                    )
                  else
                    ...items.map((item) {
                      final reason = item['reason_label'] ??
                          reasonLabels[item['reason']] ?? item['reason'] ?? '-';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_busy, color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((item['date'] as String?)?.formattedDate ?? '-',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(reason,
                                    style: GoogleFonts.poppins(color: AppColors.secondary, fontSize: 11)),
                                  if (item['notes'] != null && item['notes'].toString().isNotEmpty)
                                    Text(item['notes'],
                                      style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                              onPressed: () async {
                                try {
                                  await api.deleteBarberUnavailability(barber['id'], item['id']);
                                  await loadItems(setModal);
                                } catch (_) {
                                  if (!ctx.mounted) return;
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Gagal menghapus'), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: GoogleFonts.poppins(color: AppColors.lightGrey, fontSize: 12)),
  );
}
