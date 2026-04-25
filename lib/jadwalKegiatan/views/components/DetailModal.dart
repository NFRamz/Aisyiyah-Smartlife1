import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';

class DetailModal extends StatelessWidget {
  final KegiatanModel item;
  final JadwalKegiatanController controller;

  const DetailModal({
    super.key,
    required this.item,
    required this.controller,
  });

  // Helper untuk menampilkan modal (Static Method)
  // Cara Pakai di View: DetailModal.show(context, item, controller);
  static void show(BuildContext context, KegiatanModel item, JadwalKegiatanController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DetailModal(item: item, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic Hirarki
    String hierarchyInfo = item.wilayahNama ?? item.daerahNama ??
        item.cabangNama ?? item.rantingNama ?? "-";
    if (item.tipe == 'ranting') hierarchyInfo = "Ranting ${item.rantingNama}";

    // Return kontennya saja (DraggableScrollableSheet)
    return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.font_green_1,
                  ),
                ),
                const SizedBox(height: 10),

                // Info Grid Kecil
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    detailBadge(
                      Icons.calendar_today,
                      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(item.tanggal),
                    ),
                    detailBadge(Icons.flag, item.tipe.capitalizeFirst!),
                    if (hierarchyInfo.isNotEmpty)
                      detailBadge(Icons.apartment, hierarchyInfo),
                  ],
                ),

                const Divider(height: 30),

                if (item.lokasi != null && item.lokasi!.isNotEmpty) ...[
                  const Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item.lokasi!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                ],

                const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  item.deskripsi ?? "-",
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),

                const SizedBox(height: 24),

                if (item.googleMapsLink != null && item.googleMapsLink!.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.font_green_1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text("Buka di Google Maps", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Get.back();
                      controller.openMap(item.googleMapsLink!);
                    },
                  ),
              ],
            ),
          );
        });
  }

  Widget detailBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }
}