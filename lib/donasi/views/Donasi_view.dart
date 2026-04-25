import 'package:aisyiyah_smartlife/components/search/SearchAndFilter.dart';
import 'package:aisyiyah_smartlife/core/utils/Pick_location.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/Donasi_controller.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/RiwayatDonasi_view.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/components/CardDonasi.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class Donasi_view extends GetView<Donasi_controller> {
  Donasi_view({super.key});

  late final List<Map<String, dynamic>> filters = [
    {"hint":"Wilayah", "selectedValue":controller.selectedWilayah, "onTap": Pick_location(controller).pickWilayah},
    {"hint":"Daerah", "selectedValue":controller.selectedDaerah, "onTap": Pick_location(controller).pickDaerah},
    {"hint":"Cabang", "selectedValue":controller.selectedCabang, "onTap": Pick_location(controller).pickCabang},
    {"hint":"Ranting", "selectedValue":controller.selectedRanting, "onTap": Pick_location(controller).pickRanting}
  ];

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
            'Program Donasi', // Judul
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.green_1,
          centerTitle: true,
          actions: [
            Obx(() => controller.isPimpinan.value
                ? IconButton(
                    icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
                    tooltip: 'Kelola Donasi',
                    onPressed: () {
                      // Navigasi ke Halaman Kelola Donasi
                      // Get.toNamed(Routes.KELOLADONASI);
                    },
                  )
                : const SizedBox.shrink()),
            IconButton(
              icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
              onPressed: () {
                // Navigasi ke Halaman Riwayat Transaksi
                Get.to(() => RiwayatDonasi_view());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SearchAndFilter(controller, filters),
            Expanded(
              child: Obx(() {
                final dataList = controller.hasActiveFilter
                    ? controller.searchResults
                    : controller.donasiList;

                if (dataList.isEmpty) {
                  return Center(
                    child: Text("Belum ada program donasi", style: GoogleFonts.poppins()),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Maksimal 2 grid untuk card persegi panjang
                    int crossCount = constraints.maxWidth > 800 ? 2 : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dataList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 145, // Tinggi fixed sesuai tinggi CardDonasi + margin
                      ),
                      itemBuilder: (context, index) =>
                          CardDonasi(data: dataList[index], isHistory: false),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Obx(() => controller.isPimpinan.value
            ? FloatingActionButton(
                onPressed: () {
                  // Navigasi ke Halaman Kelola Donasi
                  Get.toNamed(Routes.KELOLADONASI);
                },
                backgroundColor: AppColors.green_1,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox.shrink()),
      );
    });
  }




}