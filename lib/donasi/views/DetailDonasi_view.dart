import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/DetailDonasi_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class DetailDonasi_view extends GetView<DetailDonasi_controller> {
  const DetailDonasi_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final data = controller.data.value;
      if (data == null) return const Scaffold(body: Center(child: Text("Data error")));

      // Format Tanggal
      String dateText = "";
      if (data['created_at'] != null) {
        final dt = DateTime.parse(data['created_at']);
        dateText = DateFormat('dd MMMM yyyy').format(dt);
      }

      // Format Nominal
      bool isFix = data['fix_amount'] ?? false;
      String nominalText = isFix
          ? NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
          .format(data['nominal'] ?? 0)
          : "Nominal Bebas";

      return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // APP BAR GAMBAR
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: AppColors.green_1,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  data['gambar'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(color: Colors.grey),
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                child: const BackButton(color: Colors.black),
              ),
            ),

            // KONTEN BODY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal
                    Text(
                      "Diposting pada $dateText",
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),

                    // Judul
                    Text(
                      data['nama'] ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nominal Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.green_1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Target/Paket: $nominalText",
                        style: GoogleFonts.poppins(
                            color: AppColors.green_1,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Deskripsi Header
                    Text(
                      "Tentang Donasi",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Deskripsi Isi
                    Text(
                      data['deskripsi'] ?? '-',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.6
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),

        // TOMBOL DONASI STICKY DI BAWAH
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,-5))],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Panggil fungsi pembayaran
              // controller.bayarDonasi(data);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green_1,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Donasi Sekarang",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
        ),
      );
    });
  }
}