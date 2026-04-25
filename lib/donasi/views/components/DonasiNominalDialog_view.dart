import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';

class DonasiNominalDialog_view extends StatelessWidget {
  final String namaDonasi;
  final Function(double) onNominalSubmitted; // Callback untuk mengirim data balik

  DonasiNominalDialog_view({
    Key? key,
    required this.namaDonasi,
    required this.onNominalSubmitted,
  }) : super(key: key);

  final TextEditingController _nominalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Masukkan Nominal",
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Donasi untuk: $namaDonasi",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: "Rp ",
              hintText: "Min. 10.000",
              filled: true,
              fillColor: AppColors.cream_2, // Sesuaikan warna
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(), // Tutup dialog
          child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            // Validasi Input Sederhana (UI Only)
            String cleanInput = _nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
            double amount = double.tryParse(cleanInput) ?? 0;

            if (amount < 10000) {
              Get.snackbar("Nominal Kurang", "Minimal donasi adalah Rp 10.000",
                  backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            } else {
              Get.back(); // Tutup dialog dulu
              onNominalSubmitted(amount); // Kirim data ke Controller
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green_1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text("Lanjut Bayar", style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    );
  }
}