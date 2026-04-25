import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/RiwayatDonasi_controller.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/components/CardDonasi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RiwayatDonasi_view extends StatelessWidget {
  RiwayatDonasi_view({super.key});
  final RiwayatDonasi_controller controller = Get.put(RiwayatDonasi_controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Donasi', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: AppColors.green_1,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: AppColors.cream_3,
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        if (controller.riwayatList.isEmpty) {
          return Center(child: Text("Belum ada riwayat donasi", style: GoogleFonts.poppins()));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.riwayatList.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // Pastikan CardDonasi menerima data transaksi yang sudah di-join dengan data donasi
            return CardDonasi(
                data: controller.riwayatList[index],
                isHistory: true
            );
          },
        );
      }),
    );
  }
}