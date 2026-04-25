import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/profile/controllers/DetailStats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class DetailStats_view extends GetView<DetailStats_controller> {
  const DetailStats_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.font_green_1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          // Memanipulasi judul agar terlihat seperti "Daftar Cabang" bukan "Total Cabang"
          controller.titlePage.replaceFirst('Total', 'Daftar'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          // Tombol Copy
          IconButton(
            tooltip: "Salin Teks",
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: controller.copyToClipboard,
          ),
          // Tombol Share
          IconButton(
            tooltip: "Bagikan",
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: controller.shareToApps,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.font_green_1));
        }

        if (controller.listData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  "Data Kosong",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.listData.length,
          itemBuilder: (context, index) {
            final item = controller.listData[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.font_green_1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.font_green_1,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  item['nama_item'] ?? 'Tanpa Nama',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                // Jika ingin menampilkan sub-info (misal kode wilayah/email), buka komen ini:
                // subtitle: Text(
                //   item['lokasi_item'] ?? '',
                //   style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                // ),
              ),
            );
          },
        );
      }),
    );
  }
}
