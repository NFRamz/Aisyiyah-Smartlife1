import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
class LayananCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const LayananCard({required this.data});

  // Konfigurasi Warna dan Icon
  static final Map<String, dynamic> _socialConfig = {
    'whatsapp': {
      'icon': Icons.chat,
      'color': const Color(0xFF25D366), // Brand Color WA
      'label': 'WhatsApp',
    },
    'instagram': {
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE4405F), // Brand Color IG
      'label': 'Instagram',
      'baseUrl': 'https://instagram.com/',
    },
    'facebook': {
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2), // Brand Color FB
      'label': 'Facebook',
      'baseUrl': 'https://facebook.com/',
    },
    'twitter': {
      'icon': Icons.alternate_email,
      'color': const Color(0xFF1DA1F2), // Brand Color Twitter
      'label': 'Twitter',
      'baseUrl': 'https://twitter.com/',
    },
    'website': {
      'icon': Icons.language,
      'color': Colors.blueGrey,
      'label': 'Website',
    },
    'maps': {
      'icon': Icons.location_on,
      'color': const Color(0xFFEA4335), // Brand Color Google Maps
      'label': 'Maps',
    },
    'email': {
      'icon': Icons.email,
      'color': const Color(0xFFDB4437), // Brand Color Gmail
      'label': 'Email',
    },
  };

  @override
  Widget build(BuildContext context) {
    final String namaSingkat  = data['nama'] ?? 'Layanan';
    final String? namaPanjang = data['nama_panjang'];
    final String deskripsi    = data['deskripsi'] ?? 'Tidak ada deskripsi.';
    final Map<String, dynamic> socialMedia = data['social_media'] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

          // Header
          title: Text(
            namaSingkat,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF4CAF50),
            ),
          ),
          subtitle: (namaPanjang != null && namaPanjang.isNotEmpty) ? Text(namaPanjang, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)) : null,
          iconColor: Colors.grey,
          collapsedIconColor: Colors.grey,

          // Isi Accordion
          children: [
            const Divider(),
            const SizedBox(height: 8),
            // Deskripsi
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                deskripsi,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // Social Media Buttons (Capsule Style)
            if (socialMedia.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10, // Jarak horizontal antar tombol
                  runSpacing: 10, // Jarak vertikal jika turun baris
                  children: socialMedia.entries.map((entry) {
                    final key    = entry.key.toLowerCase();
                    final val    = entry.value.toString();
                    final config = _socialConfig[key];

                    // Skip jika tipe sosmed tidak dikenali
                    if (config == null) return const SizedBox.shrink();

                    String url = val;

                    // --- LOGIKA CERDAS PEMBENTUKAN LINK ---
                    if (key == 'whatsapp') {
                      // Hapus karakter non-digit, tambahkan kode negara jika perlu
                      url = "https://wa.me/${_formatPhone(val)}";
                    } else if (key == 'phone') {
                      url = "tel:$val";
                    } else if (key == 'email') {
                      url = "mailto:$val";
                    } else {
                      // Cek apakah val sudah berupa link penuh (www atau http)
                      if (val.startsWith('http') || val.startsWith('www')) {
                        url = _ensureHttp(val);
                      }
                      // Jika bukan link penuh, asumsikan username dan gabung dengan baseUrl
                      else if (config.containsKey('baseUrl')) {
                        final cleanVal = val.replaceAll('@', '');
                        url = "${config['baseUrl']}$cleanVal";
                      }
                      // Fallback
                      else {
                        url = _ensureHttp(val);
                      }
                    }

                    return _buildCapsuleButton(
                        config['icon'],
                        config['color'],
                        config['label'],
                        url
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Kapsul
  Widget _buildCapsuleButton(IconData icon, Color color, String label, String actionUrl) {
    return Material(
      color: color, // Warna background sesuai brand
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async {
          final uri = Uri.parse(actionUrl);
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              await launchUrl(uri);
            }
          } catch (e) {
            Get.snackbar("Gagal", "Tidak dapat membuka link", snackPosition: SnackPosition.BOTTOM);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Agar lebar menyesuaikan konten
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPhone(String number) {
    String clean = number.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    return clean;
  }

  String _ensureHttp(String url) {
    if (!url.startsWith('http')) {
      return 'https://$url';
    }
    return url;
  }
}