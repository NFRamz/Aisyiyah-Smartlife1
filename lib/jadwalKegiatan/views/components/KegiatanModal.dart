import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/KegiatanModal_controller.dart';

class KegiatanModal_view extends StatelessWidget {
  final KegiatanModel? item;
  final JadwalKegiatanController parentController;

  const KegiatanModal_view({
    super.key,
    this.item,
    required this.parentController,
  });

  static void show(BuildContext context, JadwalKegiatanController controller, KegiatanModel? item) {
    Get.delete<KegiatanModal_controller>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KegiatanModal_view(parentController: controller, item: item),
    );
  }


  @override
  Widget build(BuildContext context) {

    final controller     = Get.put(KegiatanModal_controller(parentController: parentController, item: item));
    final bool isEditing = item != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Kegiatan" : "Tambah Kegiatan"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.namaController,
                decoration: const InputDecoration(labelText: "Nama Kegiatan", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.lokasiController,
                decoration: const InputDecoration(
                    labelText: "Nama Lokasi / Tempat",
                    hintText: "Contoh: Rumah bu Iin",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.deskripsiController,
                decoration: const InputDecoration(
                    labelText: "Deskripsi",
                    hintText: "Detail kegiatan...",
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.mapsController,
                decoration: const InputDecoration(
                    labelText: "Link Google Maps",
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text("Waktu Pelaksanaan:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // WAKTU PELAKSANAAN (Obx untuk update UI saat tanggal berubah)
              Obx(() => Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030));
                        if (picked != null) controller.selectedDate.value = picked;
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: "Tanggal Acara", border: OutlineInputBorder()),
                        child: Text(DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: controller.selectedTime.value);
                        if (picked != null) controller.selectedTime.value = picked;
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: "Jam Acara", border: OutlineInputBorder()),
                        child: Text(controller.selectedTime.value.format(context)),
                      ),
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 20),
              const Divider(thickness: 2),
              // --- DROPDOWN FREKUENSI ULANG ---
              Obx(() => InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Ulangi Kegiatan",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedFrequency.value,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text("Tidak Pernah (Sekali)")),
                      DropdownMenuItem(value: 'mingguan', child: Text("Setiap Minggu")),
                      DropdownMenuItem(value: 'bulanan', child: Text("Setiap Bulan")),
                      DropdownMenuItem(value: 'tahunan', child: Text("Setiap Tahun")),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.selectedFrequency.value = value;
                    },
                  ),
                ),
              )),

              const SizedBox(height: 8),
              // Info Message
              Obx(() => controller.selectedFrequency.value != 'none'
                  ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Sistem akan otomatis memindahkan tanggal kegiatan ke periode berikutnya jika tanggal saat ini sudah terlewat.", style: TextStyle(fontSize: 12, color: Colors.blue.shade900))),
                  ],
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),

      actions: [
        if (isEditing)
          TextButton(
            onPressed: controller.deleteItem,
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.font_green_1, padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
          onPressed: controller.saveItem,
          child: const Text("Simpan", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}