import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/KelolaDonasi_controller.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/FormDonasi_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class KelolaDonasi_view extends GetView<KelolaDonasi_controller> {
  const KelolaDonasi_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Donasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.green_1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchDonasiByScope(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.donasiList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volunteer_activism_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Belum ada program donasi",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDonasiByScope(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.donasiList.length,
            itemBuilder: (context, index) {
              final donasi = controller.donasiList[index];
              final nominal = double.tryParse(donasi['nominal'].toString()) ?? 0;
              final isFix = donasi['fix_amount'] ?? false;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigasi ke detail atau edit jika diperlukan
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Program Donasi
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          image: donasi['gambar'] != null && donasi['gambar'] != ""
                              ? DecorationImage(
                                  image: NetworkImage(donasi['gambar']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: donasi['gambar'] == null || donasi['gambar'] == ""
                            ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    donasi['nama'] ?? 'Tanpa Nama',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isFix ? Colors.blue[50] : Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isFix ? 'Fix Amount' : 'Bebas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: isFix ? Colors.blue[700] : Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (isFix)
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(nominal),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.green_1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              donasi['deskripsi'] ?? 'Tidak ada deskripsi',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final result = await Get.to(() => const FormDonasi_view(), arguments: donasi);
                                    if (result == true) {
                                      controller.fetchDonasiByScope();
                                    }
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text("Edit"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _confirmDelete(context, donasi),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text("Hapus"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(() => (controller.roleFullAccess == true)
          ? FloatingActionButton(
              backgroundColor: AppColors.green_1,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Get.to(() => const FormDonasi_view());
                if (result == true) {
                  controller.fetchDonasiByScope();
                }
              },
            )
          : const SizedBox.shrink()),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> donasi) {
    Get.defaultDialog(
      title: "Hapus Program",
      middleText: "Yakin ingin menghapus '${donasi['nama']}'?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteDonasi(donasi['id'], donasi['gambar']);
      },
    );
  }
}
