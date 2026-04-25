import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aisyiyah_smartlife/core/values/AppColors.dart';

Widget Card_jadwalSection(BuildContext context, dynamic controller) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Kegiatan',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.JADWALKEGIATAN),
              child: Text('Lihat Semua', style: GoogleFonts.poppins(fontSize:12 ,color: Colors.green.shade600, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Obx(() {
        if (controller.kegiatanFuture.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.kegiatanFuture.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Terjadi kesalahan saat memuat data.'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Tidak ada jadwal kegiatan mendatang.'),
              );
            }

            // Ambil  3 data teratas
            final displayedDocs = snapshot.data!.take(3).toList();

            return ListView.separated(
              itemCount: displayedDocs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                var doc = displayedDocs[index];
                Map<String, dynamic> data = doc;
                String tanggal = controller.formatTanggal(data['tanggal']);
                String tipe = data['tipe'] ?? '';
                // Logika Icon berdasarkan Tipe
                IconData iconData = Icons.event;
                if (tipe.toLowerCase() == 'wilayah') iconData = Icons.public;
                else if (tipe.toLowerCase() == 'daerah') iconData = Icons.account_balance;
                else if (tipe.toLowerCase() == 'cabang') iconData = Icons.home_work;
                else if (tipe.toLowerCase() == 'ranting') iconData = Icons.home;

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.cream_1,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.cream_4, borderRadius: BorderRadius.circular(10)),
                        child: Icon(iconData, color: AppColors.font_green_1),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nama'] ?? '',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${data['lokasi'] ?? ''} • $tanggal',
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }),
    ],
  );
}