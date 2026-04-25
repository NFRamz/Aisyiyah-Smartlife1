import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/bindings/ExportExcelBinding.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/ExportExcelView.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/AlarmModal_view.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/FilterModal.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/JadwalKegiatanOtomatisModal.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/views/components/KegiatanModal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';

import 'package:aisyiyah_smartlife/core/values/AppColors.dart';


import 'components/SearchBarWidget.dart';
import 'components/KegiatanCard.dart';
import 'components/DetailModal.dart';


class JadwalKegiatanView extends GetView<JadwalKegiatanController> {
  const JadwalKegiatanView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kegiatan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.font_green_1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Di dalam AppBar actions[]
          Obx(() {
            if (controller.currentUser.value == null) return const SizedBox.shrink();
            final user = controller.currentUser.value!;
            bool isEligible = (user.role.toLowerCase() != 'anggota') &&
                (user.full_access == true) &&
                (user.wilayahId != null);

            if (isEligible) {
              return IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: "Export Excel",
                onPressed: () {
                  // NAVIGASI KE HALAMAN BARU
                  // Kita kirim data user saat ini sebagai arguments agar controller baru tahu siapa yang login
                  Get.to(
                          () => const ExportExcelView(),
                      binding: ExportExcelBinding(),
                      arguments: controller.currentUser.value
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => FilterModal.show(context,controller),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.displayedKegiatan.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada kegiatan.', style: TextStyle(color: Colors.grey[600])),
                      TextButton(onPressed: controller.fetchKegiatan, child: const Text("Refresh"))
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchKegiatan,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.displayedKegiatan.length,
                  itemBuilder: (context, index) {
                    final item = controller.displayedKegiatan[index];
                    return KegiatanCard(
                      item: item,
                      controller: controller,
                      // Hubungkan aksi Tap ke components/DetailModal di View
                      onTapDetail: (kegiatan) => DetailModal.show(context, item, controller),
                      // Hubungkan aksi Long Press ke fungsi _showKegiatanDialog di View
                      onLongPressEdit: (kegiatan) => KegiatanModal_view.show(context,controller, item),
                    );
                  },
                ),
              );

            }),
          ),
        ],
      ),
      // --- MODIFIED: Floating Action Button Section ---
      floatingActionButton: Obx(() {

        if (controller.isLoading.value) return const SizedBox.shrink();
        final user = controller.currentUser.value!;
        bool isEligible = (user.role.toLowerCase() != 'anggota') &&
            (user.full_access == true) &&
            (user.wilayahId != null);

        if (controller.currentUser.value == null) return const SizedBox.shrink();

        if (isEligible){
          return Column(

            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: "btnAlarm",
                backgroundColor: Colors.orange[700],
                child: const Icon(Icons.alarm, color: Colors.white),
                onPressed: () => AlarmModal.show(context),
                tooltip: "Atur Pengingat",
              ),
              // TOMBOL BARU: JADWAL OTOMATIS
              FloatingActionButton.small(
                heroTag: "btnAutoSchedule",
                backgroundColor: Colors.blue[600],
                child: const Icon(Icons.schedule_send, color: Colors.white),
                onPressed: () => JadwalKegiatanOtomatisModal.show(context, controller),
                tooltip: "Kelola Jadwal Otomatis",
              ),
              const SizedBox(height: 12),
              // TOMBOL EXISITING: TAMBAH
              FloatingActionButton(
                  heroTag: "btnAdd",
                  backgroundColor: AppColors.font_green_1,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => KegiatanModal_view.show(context,controller,null)
              ),
            ],
          );
        }else{
          return const SizedBox.shrink();
        }
      }),
    );
  }
}