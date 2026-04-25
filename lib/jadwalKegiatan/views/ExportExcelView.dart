import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/ExportExcelController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:intl/intl.dart';


class ExportExcelView extends GetView<ExportExcelController> {
  const ExportExcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export Data Kegiatan", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.font_green_1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (Header Info & Tanggal sama seperti sebelumnya) ...

            // Tanggal Picker (Kode sama, dipersingkat disini)
            const Text("Pilih Rentang Tanggal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _datePicker(context, "Mulai", controller.startDate)),
                const SizedBox(width: 16),
                Expanded(child: _datePicker(context, "Sampai", controller.endDate)),
              ],
            ),
            const SizedBox(height: 24),

            // Pilih Scope
            const Text("Pilih Cakupan Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedScope.value,
                  items: controller.getScopeItems(),
                  onChanged: (val) {
                    if (val != null) controller.selectedScope.value = val;
                  },
                ),
              )),
            ),

            // --- BAGIAN BARU: PILIH LOKASI SPESIFIK (CHECKBOX) ---
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isFetchingLocations.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
              }

              // Jika ada opsi lokasi tersedia (Logic Atasan ke Bawahan)
              if (controller.availableLocations.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pilih ${controller.selectedScope.value.capitalizeFirst} Spesifik (Opsional)",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 5),
                    const Text("Biarkan kosong untuk memilih SEMUA.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),

                    Container(
                      height: 200, // Scrollable Area
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: ListView.builder(
                        itemCount: controller.availableLocations.length,
                        itemBuilder: (ctx, index) {
                          final loc = controller.availableLocations[index];
                          final id = loc['id']!;
                          final nama = loc['nama']!;

                          return Obx(() {
                            bool isSelected = controller.selectedLocationIds.contains(id);
                            return CheckboxListTile(
                              title: Text(nama, style: const TextStyle(fontSize: 14)),
                              value: isSelected,
                              activeColor: AppColors.font_green_1,
                              dense: true,
                              onChanged: (val) {
                                if(val == true) {
                                  controller.selectedLocationIds.add(id);
                                } else {
                                  controller.selectedLocationIds.remove(id);
                                }
                              },
                            );
                          });
                        },
                      ),
                    )
                  ],
                );
              }

              // Jika Scope Bawah ke Atas (Misal Ranting pilih Daerah)
              // Kita kasih info ke user bahwa dia cuma bisa lihat daerah dia sendiri
              if (controller.selectedScope.value != 'all' && controller.availableLocations.isEmpty) {
                String role = controller.currentUser.role.toLowerCase();
                // Logic text sederhana
                if ((role.contains('ranting') && controller.selectedScope.value == 'daerah')) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade50,
                    child: const Text("Catatan: Anda hanya dapat mengekspor data Daerah tempat ranting Anda bernaung.", style: TextStyle(fontSize: 12, color: Colors.orange)),
                  );
                }
              }

              return const SizedBox.shrink();
            }),

            const SizedBox(height: 40),
            Obx(() => ElevatedButton.icon(
              // ... (Tombol Download sama seperti sebelumnya) ...
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.font_green_1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isLoading.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(controller.isLoading.value ? "Sedang Memproses..." : "Download Excel"),
              onPressed: controller.isLoading.value ? null : () => controller.processExport(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context, String label, Rx<DateTime> dateObs) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dateObs.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) dateObs.value = picked;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Obx(() => Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.font_green_1),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(dateObs.value), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}