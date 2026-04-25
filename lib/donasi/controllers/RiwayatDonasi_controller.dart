import 'package:aisyiyah_smartlife/modules/donasi/views/XenditWebView_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatDonasi_controller extends GetxController {
  final _supabase = Supabase.instance.client;

  var riwayatList = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      // Join tabel transaksi dengan tabel donasi
      // Agar bisa menampilkan Judul dan Gambar Donasi di card riwayat
      final response = await _supabase
          .from('transaksi_rk')
          .select('*, donasi_id(nama, gambar)')
          .eq('profiles_id', user.id) // Filter hanya milik user login
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      riwayatList.assignAll(data);

    } catch (e) {
      Get.snackbar("Error", "Gagal memuat riwayat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Dipanggil saat tombol "Lanjut Bayar" diklik di CardDonasi
  void continuePayment(String? paymentLink) {
    if (paymentLink != null && paymentLink.isNotEmpty) {
      Get.to(() => XenditWebView_view(url: paymentLink));
    } else {
      Get.snackbar("Gagal", "Link pembayaran tidak valid atau kadaluarsa",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> refreshData() async => await fetchRiwayat();
}