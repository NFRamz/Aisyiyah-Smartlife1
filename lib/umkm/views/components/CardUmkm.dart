import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


Widget CardUmkm(BuildContext context, Map<String, dynamic> data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        SizedBox(
          height: 140,
          child: Image.network(
            data['gambar'] ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 140,
              width: double.infinity,
              color: AppColors.green_5,
              child: const Icon(Icons.store_mall_directory_sharp, size: 80, color: AppColors.green_2,),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA UMKM
                Flexible(
                  child: Text(data['nama'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                ),

                const Spacer(),
                // BUTTONS ROW
                Row(
                  children: [
                    // CEK LOKASI BUTTON
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          final url = data['maps_link'];
                          if (url != null && url.isNotEmpty) {
                            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.font_green_1.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 15, color: Colors.green),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "Cek Lokasi",
                                  style: GoogleFonts.poppins(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ARROW BUTTON
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed('/umkm/detail/${data['id']}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.font_green_1,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
