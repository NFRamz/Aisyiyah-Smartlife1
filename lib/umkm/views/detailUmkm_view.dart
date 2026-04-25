import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pastikan package ini ada
import '../controllers/detailUmkm_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailUmkmView extends GetView<DetailUmkmController> {
  const DetailUmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final data = controller.data.value;

      if (data == null) {
        return const Scaffold(
            body: Center(child: Text("Data tidak ditemukan")));
      }

      String createdAtText = "Tidak diketahui";
      try {
        if (data['created_at'] != null) {
          final dt = DateTime.parse(data['created_at']);
          createdAtText =
          "${dt.day}/${dt.month}/${dt.year}";
        }
      } catch (_) {}

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            data['nama'] ?? 'Detail UMKM',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR UTAMA ---
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    data['gambar'] ?? '',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      width: double.infinity,
                      color: AppColors.green_5,
                      child: const Icon(Icons.store_mall_directory_rounded,
                          size: 80, color: AppColors.green_2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- JUDUL & INFO ---
              Text(
                data['nama'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    "Terdaftar sejak $createdAtText",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- DESKRIPSI ---
              Text(
                "Deskripsi",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['deskripsi'] ?? 'Tidak ada deskripsi.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 32),

              // --- BAGIAN SOCIAL MEDIA (CTA) ---
              if (data['social_media'] != null &&
                  (data['social_media'] as Map).isNotEmpty) ...[
                Text(
                  "Informasi Kontak & Social Media",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSocialMediaGrid(data['social_media']),
                const SizedBox(height: 32),
              ],

              // --- TOMBOL LOKASI (STICKY BOTTOM FEEL) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = data['maps_link'];
                    if (url != null && url.isNotEmpty) {
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar("Info", "Link lokasi belum tersedia");
                    }
                  },
                  icon: const Icon(Icons.map_outlined, color: Colors.white),
                  label: Text(
                    "Lihat Lokasi di Maps",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.font_green_1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.font_green_1.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  // --- WIDGET BUILDER: GRID SOCIAL MEDIA ---
  Widget _buildSocialMediaGrid(dynamic socialData) {
    if (socialData is! Map) return const SizedBox.shrink();
    Map<String, dynamic> socials = Map.from(socialData);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: socials.entries.map((entry) {
        return _buildSocialButton(entry.key, entry.value.toString());
      }).toList(),
    );
  }

  Widget _buildSocialButton(String key, String url) {
    if (url.isEmpty) return const SizedBox.shrink();

    // Tentukan Style berdasarkan Platform
    final style = _getSocialStyle(key);
    if (style == null) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: style?.bgColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: style.bgColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(style?.icon, size: 20, color: style.bgColor),
              const SizedBox(width: 8),
              Text(
                style.label,
                style: GoogleFonts.poppins(
                  color: style.bgColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk Warna & Icon (Menggunakan FontAwesome)
  SocialStyle? _getSocialStyle(String key) {
    key = key.toLowerCase();

    if (key.contains('whatsapp')) {
      return SocialStyle("WhatsApp", FontAwesomeIcons.whatsapp, const Color(0xFF25D366));
    } else if (key.contains('instagram')) {
      return SocialStyle("Instagram", FontAwesomeIcons.instagram, const Color(0xFFE1306C));
    } else if (key.contains('facebook')) {
      return SocialStyle("Facebook", FontAwesomeIcons.facebook, const Color(0xFF1877F2));
    } else if (key.contains('tiktok')) {
      return SocialStyle("TikTok", FontAwesomeIcons.tiktok, Colors.black);
    } else if (key.contains('youtube')) {
      return SocialStyle("YouTube", FontAwesomeIcons.youtube, const Color(0xFFFF0000));
    } else if (key.contains('twitter') || key.contains('x.com')) {
      return SocialStyle("X / Twitter", FontAwesomeIcons.xTwitter, Colors.black87);
    } else if (key.contains('web')) {
      return SocialStyle("Website", FontAwesomeIcons.globe, Colors.blueGrey);
    }
    return null;
  }
}

// Class Model Sederhana untuk Styling
class SocialStyle {
  final String label;
  final IconData icon;
  final Color bgColor;

  SocialStyle(this.label, this.icon, this.bgColor);
}