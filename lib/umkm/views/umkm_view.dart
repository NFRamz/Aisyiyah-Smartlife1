import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/umkm/views/components/CardUmkm.dart';
import 'package:aisyiyah_smartlife/core/utils/Pick_location.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/umkm_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'KelolaUmkm_view.dart';

class UmkmView extends GetView<UmkmController> {
   const UmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        backgroundColor: AppColors.cream_3,
        appBar: AppBar(
          title: Text(
            'UMKM Aisyiyah',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.font_green_1,
          elevation: 1,
          centerTitle: true,
          actions: [
            if (controller.showEditButton)
              IconButton(
                onPressed: () => Get.toNamed(Routes.KELOLAUMKM),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: Obx(() {
                final dataList = controller.hasActiveFilter
                    ? controller.searchResults
                    : controller.umkmList;

                if (dataList.isEmpty) {
                  return Center(
                    child: Text(
                      controller.hasActiveFilter
                          ? "Tidak ada hasil"
                          : "Belum ada data UMKM",
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int cross = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                        ? 3
                        : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dataList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 280,
                      ),
                      itemBuilder: (context, index) =>
                          CardUmkm(context, dataList[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  // ------------------ SEARCH + FILTER CHIP ---------------------
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      color: AppColors.cream_3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BOX
          TextField(
            controller: controller.searchController,
            onChanged: (value) => controller.updateFiltersAndSearch(
              query: value,
              ranting: controller.selectedRanting.value,
              cabang: controller.selectedCabang.value,
              daerah: controller.selectedDaerah.value,
              wilayah: controller.selectedWilayah.value,
            ),
            decoration: InputDecoration(
              hintText: 'Cari UMKM...',
              filled: true,
              fillColor: AppColors.cream_3,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.font_green_1, width: 3),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.searchController.clear();
                  controller.updateFiltersAndSearch(
                    query: "",
                    ranting: controller.selectedRanting.value,
                    cabang: controller.selectedCabang.value,
                    daerah: controller.selectedDaerah.value,
                    wilayah: controller.selectedWilayah.value,
                  );
                },
              )
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // FILTER ROW (Scrollable Horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  hint: "Semua Wilayah",
                  selectedValue: controller.selectedWilayah,
                  onTap:Pick_location(controller).pickWilayah,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  hint: "Semua Daerah",
                  selectedValue: controller.selectedDaerah,
                  onTap: Pick_location(controller).pickDaerah,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  hint: "Semua Cabang",
                  selectedValue: controller.selectedCabang,
                  onTap: Pick_location(controller).pickCabang,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  hint: "Semua Ranting",
                  selectedValue: controller.selectedRanting,
                  onTap: Pick_location(controller).pickRanting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChip({
    required String hint,
    required RxnString selectedValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        bool isSelected = selectedValue.value != null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.font_green_1 : AppColors.cream_2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.font_green_1 : Colors.grey.shade500,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                selectedValue.value ?? hint,
                style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontSize: 13, fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: isSelected ? Colors.white : Colors.black54,
                size: 20,
              ),
            ],
          ),
        );
      }),
    );
  }
}