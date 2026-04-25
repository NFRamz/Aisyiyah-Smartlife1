import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/Donasi_controller.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/RiwayatDonasi_controller.dart'; // Pastikan import ini ada
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CardDonasi extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isHistory; // Flag untuk mode Riwayat

  const CardDonasi({
    Key? key,
    required this.data,
    this.isHistory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Parsing Data Judul & Gambar
    final String title = isHistory
        ? (data['donasi_id']?['nama'] ?? 'Donasi Terhapus')
        : data['nama'] ?? '';

    final String image = isHistory
        ? (data['donasi_id']?['gambar'] ?? '')
        : data['gambar'] ?? '';

    // 2. Logic Parsing Nominal
    String? nominalDisplay;
    if (isHistory) {
      nominalDisplay = _formatCurrency(data['nominal']);
    } else {
      bool isFix = data['fix_amount'] ?? false;
      if (isFix) {
        nominalDisplay = _formatCurrency(data['nominal']);
      }
    }

    // 3. Logic Emblem & Warna (Wilayah/Daerah/dll) - Konsisten dengan Jadwal Kegiatan
    String emblemText = "Aisyiyah";
    Color chipColor = Colors.grey;

    if (!isHistory && data['profiles'] != null) {
      final p = data['profiles'];
      if (p['ranting_id'] != null) {
        emblemText = "Ranting";
        chipColor = AppColors.green_1;
      } else if (p['cabang_id'] != null) {
        emblemText = "Cabang";
        chipColor = Colors.blue;
      } else if (p['daerah_id'] != null) {
        emblemText = "Daerah";
        chipColor = Colors.orange;
      } else if (p['wilayah_id'] != null) {
        emblemText = "Wilayah";
        chipColor = Colors.purple;
      }
    }

    // 4. LOGIC WAKTU EXPIRED (WIB/WITA/WIT Otomatis)
    String? expiredText;
    // Hanya hitung jika: Ini History, Status Pending, dan ada data expired_at
    if (isHistory && data['status'] == 'PENDING' && data['expired_at'] != null) {
      try {
        // Parse waktu dari server (UTC)
        DateTime serverTime = DateTime.parse(data['expired_at']);
        // Konversi ke waktu HP user (Local)
        DateTime localTime = serverTime.toLocal();
        // Format: 14 Jan 2026, 17:30
        expiredText = DateFormat('d MMM y, HH:mm', 'id_ID').format(localTime);
      } catch (_) {}
    }

    // 5. LOGIC TOMBOL BAYAR
    // Tombol muncul jika:
    // - Bukan History (Katalog Donasi Baru)
    // - ATAU History tpi statusnya PENDING (Lanjut Bayar)
    bool showPayButton = !isHistory || (isHistory && data['status'] == 'PENDING');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 145,
        child: Row(
          children: [
            // --- GAMBAR (KIRI) ---
            SizedBox(
              width: 120,
              height: double.infinity,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),

            // --- KONTEN (KANAN) ---
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // JUDUL
                        Padding(
                          padding: const EdgeInsets.only(right: 60),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // NOMINAL
                        if (nominalDisplay != null)
                          Text(
                            nominalDisplay,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.green_1,
                            ),
                          ),

                        // STATUS BADGE (Khusus History)
                        if (isHistory)
                          Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(data['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data['status'] ?? 'UNKNOWN',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(data['status']),
                              ),
                            ),
                          ),

                        // TEXT BATAS WAKTU (Khusus Pending & Ada Expirednya)
                        if (expiredText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled, size: 10, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  "Batas: $expiredText",
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),

                        // TOMBOL DONASI / LANJUT BAYAR
                        if (showPayButton)
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isHistory) {
                                        // --- MODE RIWAYAT (LANJUT BAYAR) ---
                                        // Membuka link lama yg tersimpan di DB
                                        Get.find<RiwayatDonasi_controller>()
                                            .continuePayment(data['payment_link']);
                                      } else {
                                        // --- MODE KATALOG (DONASI BARU) ---
                                        // Membuat transaksi baru
                                        Get.find<Donasi_controller>()
                                            .processPayment(data);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      // Warna Orange jika Lanjut Bayar agar user 'aware'
                                      backgroundColor: isHistory ? Colors.orange : AppColors.green_1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      isHistory ? "Lanjut Bayar" : "Donasi",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // TOMBOL DETAIL (Arrow)
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: OutlinedButton(
                                  onPressed: () => Get.toNamed('/donasi/detail/${data['id']}'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    side: const BorderSide(color: AppColors.green_1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.arrow_forward, size: 16, color: AppColors.green_1),
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),

                  // EMBLEM POJOK KANAN (Jika bukan history)
                  if (!isHistory)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          emblemText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(double.tryParse(amount.toString()) ?? 0);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAID': return Colors.green;
      case 'PENDING': return Colors.orange;
      case 'FAILED': return Colors.red;
      case 'EXPIRED': return Colors.grey;
      default: return Colors.black;
    }
  }
}