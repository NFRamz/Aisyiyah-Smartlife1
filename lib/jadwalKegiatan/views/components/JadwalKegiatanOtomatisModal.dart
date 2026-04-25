import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/DetailModal.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/KegiatanModal.dart';

class JadwalKegiatanOtomatisModal extends StatelessWidget {
  final JadwalKegiatanController controller;

  const JadwalKegiatanOtomatisModal({super.key, required this.controller});

  static void show(BuildContext context, JadwalKegiatanController controller) {
    // Refresh data saat modal dibuka
    controller.fetchMyScheduled_dataKegiatan();

    showDialog(
      context: context,
      builder: (context) => JadwalKegiatanOtomatisModal(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.schedule_send, color: AppColors.font_green_1),
          SizedBox(width: 10),
          Text("Jadwal Otomatis Saya", style: TextStyle(fontSize: 18)),
        ],
      ),
      contentPadding: const EdgeInsets.only(top: 10, bottom: 20),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(() {
          if (controller.isLoadingScheduled.value) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.myScheduledData.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, size: 50, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text(
                    "Tidak ada jadwal otomatis aktif.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.myScheduledData.length,
            itemBuilder: (context, index) {
              final item = controller.myScheduledData[index];
              return _AutoScheduleCard(
                item: item,
                controller: controller,
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Tutup"),
        )
      ],
    );
  }
}

// Internal Widget khusus untuk Card sesuai request
class _AutoScheduleCard extends StatelessWidget {
  final KegiatanModel item;
  final JadwalKegiatanController controller;

  const _AutoScheduleCard({required this.item, required this.controller});

  String _getFrequencyLabel(String freq) {
    switch (freq.toLowerCase()) {
      case 'mingguan': return 'Setiap Minggu';
      case 'bulanan': return 'Setiap Bulan';
      case 'tahunan': return 'Setiap Tahun';
      default: return freq.capitalizeFirst ?? freq;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Logic Formatting Data ---

    // 1. Color Logic
    Color chipColor;
    switch (item.tipe) {
      case 'wilayah': chipColor = Colors.purple;     break;
      case 'daerah' : chipColor = Colors.orange;     break;
      case 'cabang' : chipColor = Colors.blue;       break;
      case 'ranting': chipColor = AppColors.font_green_1; break;
      default       : chipColor = Colors.grey;
    }

    // 2. Date Formatting
    final dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');
    String formattedDate = dateFormat.format(item.tanggal);
    String formattedTime = timeFormat.format(item.tanggal);

    // 3. Hierarchy Info
    String hierarchyInfo = "";
    if (item.tipe == 'wilayah') hierarchyInfo = item.wilayahNama ?? "Wilayah";
    else if (item.tipe == 'daerah') hierarchyInfo = "${item.daerahNama ?? '-'} (${item.wilayahNama ?? '-'})";
    else if (item.tipe == 'cabang') hierarchyInfo = "Cabang ${item.cabangNama ?? '-'}";
    else if (item.tipe == 'ranting') hierarchyInfo = "Ranting ${item.rantingNama ?? '-'}";

    // 4. Map Logic
    bool hasMap = item.googleMapsLink != null && item.googleMapsLink!.isNotEmpty;

    // 5. Auth Logic
    bool isMyScope = controller.canAction(item);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // Aksi Tap: Tampilkan Detail
        onTap: () => DetailModal.show(context, item, controller),
        // Aksi Long Press: Edit
        onLongPress: () {
          if (isMyScope) {
            KegiatanModal_view.show(context, controller, item);
          } else {
            Get.snackbar(
              "Info",
              "Hanya admin pembuat kegiatan yang bisa mengedit.",
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(10),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align top jika ada 2 baris
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.timer, size: 16, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (item.frekuensiUlang != null && item.frekuensiUlang != 'none')
                            const SizedBox(height: 2),

                          if (item.frekuensiUlang != null && item.frekuensiUlang != 'none')
                            Text(
                              "jadwalkan otomatis: ${_getFrequencyLabel(item.frekuensiUlang!)}",
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 1. HEADER: Judul & Tipe
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.nama,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      item.tipe.capitalizeFirst ?? item.tipe,
                      style: TextStyle(
                          color: chipColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 12),

              // 2. TANGGAL
              _infoRow(Icons.calendar_today_outlined,
                  "$formattedDate • $formattedTime WIB", Colors.black87),
              const SizedBox(height: 8),

              // 3. LOKASI
              if (item.lokasi != null && item.lokasi!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _infoRow(Icons.location_on_outlined, item.lokasi!,
                      Colors.black87),
                ),

              // 4. INFO PENYELENGGARA
              if (hierarchyInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _infoRow(Icons.apartment_outlined,
                      "Penyelenggara: $hierarchyInfo", Colors.grey[700]!),
                ),

              // 5. DESKRIPSI (Preview)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text("Klik untuk detail / Tahan untuk edit.",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

              // 6. TOMBOL MAPS
              if (hasMap)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.font_green_1,
                      side: const BorderSide(color: AppColors.font_green_1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text("Buka Google Maps"),
                    onPressed: () => controller.openMap(item.googleMapsLink!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper Internal
  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 14, color: color, height: 1.3)),
        ),
      ],
    );
  }
}