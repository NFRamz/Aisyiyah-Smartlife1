import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/components/SearchAndSort.dart';
import 'package:google_fonts/google_fonts.dart';

// Model Sederhana untuk Dropdown Item
class DropdownItemModel {
  final String id;
  final String name;
  DropdownItemModel(this.id, this.name);
}
class FilterModal extends StatelessWidget {
  final JadwalKegiatanController controller;

  const FilterModal({
    super.key,
    required this.controller,
  });

  // Helper untuk menampilkan modal (Static Method)
  // Cara Pakai di View: DetailModal.show(context, item, controller);
  static void show(BuildContext context, JadwalKegiatanController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterModal(controller: controller,),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TextButton(
              onPressed: () => controller.searchAndSort.resetFilters(),
              child: Text('Reset', style: GoogleFonts.poppins(color: const Color(0xFF4CAF50)),
              ),
            ),
            const Text("Filter Pemilik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Obx(() => SwitchListTile(
              title: const Text("Hanya Kegiatan Buatan Saya"),
              subtitle: const Text("Tampilkan kegiatan yang Anda input"),
              value: controller.searchAndSort.showOnlyMyKegiatan.value,
              activeColor: AppColors.font_green_1,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                controller.searchAndSort.setMyActivityFilter(val);
                // Tidak perlu Get.back() agar user bisa set filter lain sekalian
              },
            )),
            const Divider(),
            const Text("Filter Waktu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                filterChip("Semua", DateFilterType.all, controller),
                filterChip("Hari Ini", DateFilterType.today, controller),
                filterChip("Besok", DateFilterType.tomorrow, controller),
                filterChip("Minggu Ini", DateFilterType.thisWeek, controller),
              ],
            ),
            const SizedBox(height: 16),

// --- FILTER TEMPAT (DROPDOWNS) ---
            const Text("Filter Tempat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Pilih Tingkatan & Nama Tempat:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),

            // Horizontal Dropdowns
            Obx(() {
              // Mengambil data saat ini dari SearchAndSort
              String? selectedLevel = controller.searchAndSort.uiSelectedLevel.value;
              String? selectedPlaceId = controller.searchAndSort.uiSelectedPlaceId.value;

              return Row(
                children: [
                  // 1. Kiri: Dropdown Tingkatan (Level)
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Tingkatan",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                      items: ['Wilayah', 'Daerah', 'Cabang', 'Ranting'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        // Reset Place ID saat level berubah
                        controller.searchAndSort.setLocationFilterFromUI(val!, null);
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 2. Kanan: Dropdown Nama Tempat (Specific)
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<String>(
                      value: selectedPlaceId, // Bind ke Logic
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Nama Tempat",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                      // Jika level belum dipilih, disable dropdown kanan
                      onChanged: selectedLevel == null ? null : (val) {
                        controller.searchAndSort.setLocationFilterFromUI(selectedLevel, val);
                      },
                      // Generate items dinamis berdasarkan User Scope
                      items: _getPlaceOptions(selectedLevel).map((item) {
                        return DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis
                          ),
                        );
                      }).toList(),
                      hint: Text(selectedLevel == null ? "Pilih Kiri Dulu" : "Pilih ${selectedLevel}"),
                    ),
                  ),
                ],
              );
            }),

            const Divider(height: 30),

            const SizedBox(height:16),
            const Divider(),
            const Text("Filter Tanggal", style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: const Text("Pilih Rentang Tanggal"),
              onPressed: () async {
                final picked = await showDateRangePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2030));
                if (picked != null) {

                  controller.searchAndSort.setDateFilter(DateFilterType.dateRange, start: picked.start, end: picked.end);
                  Get.back();
                }
              },
            )
          ],
        ),
      ),
    );
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


  // --- LOGIC HELPER: Filter Place Options based on User Scope ---
  List<DropdownItemModel> _getPlaceOptions(String? selectedLevel) {
    if (selectedLevel == null) return [];

    final userProfile = controller.currentUser.value;
    if (userProfile == null) return [];

    // Normalisasi role string agar aman (kecil semua)
    final role = userProfile.role.toLowerCase();

    List<DropdownItemModel> options = [];

    // =======================================================
    // KASUS 1: PILIH WILAYAH
    // =======================================================
    if (selectedLevel == 'Wilayah') {
      // Semua level user hanya punya 1 Wilayah Induk
      // Jadi filter berdasarkan ID Wilayah user tersebut
      options = controller.searchAndSort.allWilayah
          .where((w) => w.id == userProfile.wilayahId)
          .map((w) => DropdownItemModel(w.id, w.nama)).toList();
    }

    // =======================================================
    // KASUS 2: PILIH DAERAH
    // =======================================================
    else if (selectedLevel == 'Daerah') {
      // A. Jika User adalah Pimpinan Wilayah -> LIHAT SEMUA DAERAH di Wilayahnya
      if (role.contains('wilayah')) {
        options = controller.searchAndSort.allDaerah
            .where((d) => d.wilayahId == userProfile.wilayahId)
            .map((d) => DropdownItemModel(d.id, d.nama)).toList();
      }
      // B. Jika User adalah Daerah/Cabang/Ranting -> Cuma bisa lihat DAERAH DIA SENDIRI
      else {
        options = controller.searchAndSort.allDaerah
            .where((d) => d.id == userProfile.daerahId)
            .map((d) => DropdownItemModel(d.id, d.nama)).toList();
      }
    }

    // =======================================================
    // KASUS 3: PILIH CABANG
    // =======================================================
    else if (selectedLevel == 'Cabang') {
      // A. Jika User Wilayah -> LIHAT SEMUA CABANG di Wilayahnya
      if (role.contains('wilayah')) {
        options = controller.searchAndSort.allCabang
            .where((c) => c.wilayahId == userProfile.wilayahId)
            .map((c) => DropdownItemModel(c.id, c.nama)).toList();
      }
      // B. Jika User Daerah -> LIHAT SEMUA CABANG di Daerahnya
      else if (role.contains('daerah')) {
        options = controller.searchAndSort.allCabang
            .where((c) => c.daerahId == userProfile.daerahId)
            .map((c) => DropdownItemModel(c.id, c.nama)).toList();
      }
      // C. Jika User Cabang/Ranting -> Cuma bisa lihat CABANG DIA SENDIRI
      else {
        options = controller.searchAndSort.allCabang
            .where((c) => c.id == userProfile.cabangId)
            .map((c) => DropdownItemModel(c.id, c.nama)).toList();
      }
    }

    // =======================================================
    // KASUS 4: PILIH RANTING
    // =======================================================
    else if (selectedLevel == 'Ranting') {
      // A. Jika User Wilayah -> LIHAT SEMUA RANTING di Wilayahnya
      if (role.contains('wilayah')) {
        options = controller.searchAndSort.allRanting
            .where((r) => r.wilayahId == userProfile.wilayahId)
            .map((r) => DropdownItemModel(r.id, r.nama)).toList();
      }
      // B. Jika User Daerah -> LIHAT SEMUA RANTING di Daerahnya
      // (Ini menjawab request Anda: Pimpinan Daerah bisa lihat list semua ranting di daerahnya)
      else if (role.contains('daerah')) {
        options = controller.searchAndSort.allRanting
            .where((r) => r.daerahId == userProfile.daerahId)
            .map((r) => DropdownItemModel(r.id, r.nama)).toList();
      }
      // C. Jika User Cabang -> LIHAT SEMUA RANTING di Cabangnya
      else if (role.contains('cabang')) {
        options = controller.searchAndSort.allRanting
            .where((r) => r.cabangId == userProfile.cabangId)
            .map((r) => DropdownItemModel(r.id, r.nama)).toList();
      }
      // D. Jika User Ranting -> Cuma bisa lihat RANTING DIA SENDIRI
      else {
        options = controller.searchAndSort.allRanting
            .where((r) => r.id == userProfile.rantingId)
            .map((r) => DropdownItemModel(r.id, r.nama)).toList();
      }
    }

    return options;
  }
}

Widget filterChip(String label, DateFilterType type, JadwalKegiatanController controller) {
  return Obx(() {
    final isSelected = controller.searchAndSort.activeDateFilter.value == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.font_green_1,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (bool selected) {
        if (selected) {
          controller.searchAndSort.setDateFilter(type);
        }
      },
    );
  });
}



