import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/AlarmModal_controller.dart';

class AlarmModal {

  static void show(BuildContext context, {KegiatanModel? preSelectedKegiatan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Inject Controller saat Modal dibuka
        final controller = Get.put(AlarmModalController());

        // [LOGIKA BARU] Jika ada kegiatan yang dipilih dari Card, set ke controller
        if (preSelectedKegiatan != null) {
          controller.selectedKegiatan.value = preSelectedKegiatan;
        }

        return _AlarmModalView(controller: controller);
      },
    ).whenComplete(() {
      // Hapus controller dari memori saat modal ditutup agar bersih
      Get.delete<AlarmModalController>();
    });
  }
}

class _AlarmModalView extends StatelessWidget {
  final AlarmModalController controller;
  const _AlarmModalView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Icon(Icons.alarm_add, color: AppColors.font_green_1),
              const SizedBox(width: 10),
              const Text("Atur Pengingat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // 1. PILIH KEGIATAN
          const Text("Pilih Kegiatan:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Obx(() {
            final events = controller.upcomingEvents;

            // Jika list kosong dan tidak ada yang terpilih
            if (events.isEmpty && controller.selectedKegiatan.value == null) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Tidak ada kegiatan mendatang.", style: TextStyle(color: Colors.grey)),
              );
            }

            return DropdownButtonFormField<KegiatanModel>(
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
              isExpanded: true,
              hint: const Text("Pilih kegiatan..."),
              value: controller.selectedKegiatan.value,
              // Pastikan value yang terpilih ada di dalam list items agar tidak error
              items: events.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(
                    "${k.nama} (${DateFormat('d MMM, HH:mm').format(k.tanggal)})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) => controller.selectedKegiatan.value = val,
            );
          }),

          const SizedBox(height: 16),

          // 2. WAKTU PENGINGAT
          const Text("Ingatkan Saya:", style: TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: [
                      _buildTimeChip(15, "15 Mnt"),
                      _buildTimeChip(30, "30 Mnt"),
                      _buildTimeChip(45, "30 Mnt"),
                      _buildTimeChip(60, "1 Jam"),
                      _buildTimeChip(120, "2 Jam"),
                      _buildTimeChip(180, "3 Jam"),
                      _buildTimeChip(1440, "1 Hari"),
                    ]),
          )),

          // Opsi Custom Waktu
          Obx(() => CheckboxListTile(
            title: const Text("Atur Menit Sendiri"),
            value: controller.isCustomTime.value,
            onChanged: controller.toggleCustomTime,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.font_green_1,
          )),

          Obx(() {
            if (controller.isCustomTime.value) {
              return TextField(
                controller: controller.customTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Masukkan jumlah menit sebelum acara",
                    border: OutlineInputBorder(),
                    suffixText: "Menit"
                ),
                onChanged: controller.updateCustomTime,
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),
          // TOMBOL AKSI
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.font_green_1,
                  padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              // Disable tombol jika kegiatan belum dipilih
              onPressed: controller.selectedKegiatan.value == null
                  ? null
                  : controller.setReminder,
              child: const Text("Simpan Pengingat", style: TextStyle(color: Colors.white, fontSize: 16)),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildTimeChip(int minutes, String label) {
    bool isSelected = !controller.isCustomTime.value && controller.minutesBefore.value == minutes;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.font_green_1.withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? AppColors.font_green_1 : Colors.black),
        onSelected: (val) {
          controller.setTime(minutes);
        },
      ),
    );
  }
}