import 'package:aisyiyah_smartlife/modules/donasi/views/XenditWebView_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Wajib tambahkan package ini

class DetailDonasi_controller extends GetxController {
  final _supabase = Supabase.instance.client;

  // Ambil ID dari argument navigasi
  final String donasiId = Get.parameters['id'] ?? '';

  var data = Rxn<Map<String, dynamic>>();
  var loading = true.obs;
  var isPaying = false.obs; // Loading saat proses bayar

  // Input Nominal (Hanya dipakai jika fix_amount = false)
  final nominalController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (donasiId.isNotEmpty) {
      fetchDetail();
    }
  }

  Future<void> fetchDetail() async {
    try {
      loading.value = true;
      final response = await _supabase
          .from('donasi_rk')
          .select()
          .eq('id', donasiId)
          .single();

      data.value = response;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat detail donasi");
    } finally {
      loading.value = false;
    }
  }

  /// EKSEKUSI PEMBAYARAN KE EDGE FUNCTION
  Future<void> bayarDonasi() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar("Login Diperlukan", "Silakan login untuk berdonasi",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (data.value == null) return;

    // 1. Validasi Input Nominal (Jika Sukarela)
    bool isFix = data.value!['fix_amount'] ?? false;
    double inputAmount = 0;

    if (!isFix) {
      // Jika nominal bebas, ambil dari text controller
      String cleanString = nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
      inputAmount = double.tryParse(cleanString) ?? 0;

      if (inputAmount < 10000) {
        Get.snackbar("Nominal Kurang", "Minimal donasi adalah Rp 10.000",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } else {
      // Jika fix, nilai ini sebenarnya tidak dipakai di Edge Function (karena ditimpa DB),
      // tapi kita kirim saja sebagai formalitas.
      inputAmount = double.tryParse(data.value!['nominal'].toString()) ?? 0;
    }

    try {
      isPaying.value = true;

      // 2. Panggil Edge Function
      final functionResponse = await _supabase.functions.invoke(
        'xendit-payment', // Nama function harus persis
        body: {
          'donasi_id': donasiId,
          'input_amount': inputAmount,
          'description': "Donasi: ${data.value!['nama']}",
        },
      );

      final resData = functionResponse.data;

      // Cek Error dari Server
      if (functionResponse.status != 200 || resData['error'] != null) {
        throw resData['error'] ?? "Terjadi kesalahan server";
      }

      // 3. Sukses -> Buka Link Pembayaran
      final String invoiceUrl = resData['invoice_url'];

      // Opsi A: Buka di Browser Eksternal (Lebih Aman & Mudah)
      // await launchUrl(Uri.parse(invoiceUrl), mode: LaunchMode.externalApplication);

      // Opsi B: Buka di WebView dalam Aplikasi (Lebih Seamless)
      Get.to(() => XenditWebView_view(url: invoiceUrl));

    } catch (e) {
      Get.snackbar("Gagal", "Gagal memproses pembayaran: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaying.value = false;
    }
  }
}