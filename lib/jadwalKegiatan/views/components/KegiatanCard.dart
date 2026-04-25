import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/AlarmModal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';

// [MODIFIKASI] Import AlarmModal
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/AlarmModal_view.dart';

class KegiatanCard extends StatelessWidget {
  final KegiatanModel item;
  final JadwalKegiatanController controller;

  // Callback untuk interaksi ke Parent (View)
  final Function(KegiatanModel) onTapDetail;
  final Function(KegiatanModel) onLongPressEdit;

 KegiatanCard({
    super.key,
    required this.item,
    required this.controller,
    required this.onTapDetail,
    required this.onLongPressEdit,
  });



  @override
  Widget build(BuildContext context) {
    // Cek apakah user punya hak akses edit
    final bool isMyScope = controller.canAction(item);

    // Formatting Tanggal & Waktu
    final formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(item.tanggal);
    final formattedTime = DateFormat('HH:mm').format(item.tanggal);
    final bool hasMap = item.googleMapsLink != null && item.googleMapsLink!.isNotEmpty;

    // [MODIFIKASI] Cek apakah kegiatan masih akan datang (Future)
    final bool isUpcoming = item.tanggal.isAfter(DateTime.now());

    // Logic Warna Chip & Info Hirarki
    Color chipColor;
    String hierarchyInfo = "";

    switch (item.tipe.toLowerCase()) {
      case 'wilayah':
        chipColor = Colors.purple;
        hierarchyInfo = item.wilayahNama ?? "Wilayah";
        break;
      case 'daerah':
        chipColor = Colors.orange;
        hierarchyInfo = item.daerahNama ?? "Daerah";
        break;
      case 'cabang':
        chipColor = Colors.blue;
        hierarchyInfo = item.cabangNama ?? "Cabang";
        break;
      case 'ranting':
        chipColor = AppColors.font_green_1;
        hierarchyInfo = item.rantingNama ?? "Ranting";
        break;
      default:
        chipColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // Aksi Tap: Tampilkan Detail
        onTap: () => onTapDetail(item),
        // Aksi Long Press: Edit (Jika punya akses)
        onLongPress: () {
          if (isMyScope) {
            onLongPressEdit(item);
          } else {
            Get.snackbar("Info", "Hanya admin pembuat kegiatan yang bisa mengedit.",
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(10),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER: Judul & Tipe & [TOMBOL ALARM]
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.nama,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),

                  if (isUpcoming)
                    Obx(() {
                      final bool alarmIcon = controller.hasAlarm(item.id);
                      return SizedBox(
                        width: 36, // Batasi lebar agar tidak merusak layout
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: alarmIcon? const Icon(Icons.notifications_active, color: Colors.orange, size: 24)
                              : const Icon(Icons.notifications_none_outlined, color: Colors.orange, size: 24),
                          tooltip: "Ingatkan saya",
                          onPressed: () {
                            // Buka modal dengan kegiatan ini sudah terpilih otomatis
                            AlarmModal.show(context, preSelectedKegiatan: item);
                          },
                        ),
                      );
                    }),


                  const SizedBox(width: 4),

                  // Chip Tipe
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: chipColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      item.tipe.capitalizeFirst ?? item.tipe,
                      style: TextStyle(color: chipColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 12),

              // 2. TANGGAL
              _infoRow(Icons.calendar_today_outlined, "$formattedDate • $formattedTime WIB", Colors.black87),
              const SizedBox(height: 8),

              // 3. LOKASI
              if (item.lokasi != null && item.lokasi!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _infoRow(Icons.location_on_outlined, item.lokasi!, Colors.black87),
                ),

              // 4. INFO PENYELENGGARA
              if (hierarchyInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _infoRow(Icons.apartment_outlined, "Penyelenggara: $hierarchyInfo", Colors.grey[700]!),
                ),

              // 5. DESKRIPSI (Preview)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text("Klik untuk melihat detail lengkap.", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          child: Text(text, style: TextStyle(fontSize: 14, color: color, height: 1.3)),
        ),
      ],
    );
  }
}