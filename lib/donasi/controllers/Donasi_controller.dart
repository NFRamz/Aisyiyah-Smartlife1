import 'package:aisyiyah_smartlife/modules/donasi/views/XenditWebView_view.dart';
import 'package:aisyiyah_smartlife/modules/donasi/views/components/DonasiNominalDialog_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Donasi_controller extends GetxController {
  final _supabase = Supabase.instance.client;

  // State Data
  var donasiList = <Map<String, dynamic>>[].obs; // Data asli
  var searchResults = <Map<String, dynamic>>[].obs; // Data hasil filter/search
  var loading = true.obs;

  // Filter & Search State
  var searchQuery = ''.obs;
  var selectedWilayah = RxnString();
  var selectedDaerah = RxnString();
  var selectedCabang = RxnString();
  var selectedRanting = RxnString();

  // Controller untuk Textfield Search
  final searchController = TextEditingController();

  // Role Access State
  var isPimpinan = false.obs;

  // Helper untuk cek apakah sedang ada filter aktif
  bool get hasActiveFilter =>
      searchQuery.isNotEmpty ||
          selectedWilayah.value != null ||
          selectedDaerah.value != null ||
          selectedCabang.value != null ||
          selectedRanting.value != null;

  // Mockup Data Filter (Nanti bisa diganti fetch dari DB)
  final availableWilayah = ['Jawa Timur', 'Jawa Tengah', 'DIY'];
  final availableDaerah = ['Malang', 'Surabaya', 'Sidoarjo'];
  final availableCabang = ['Lowokwaru', 'Klojen'];
  final availableRanting = ['Ranting A', 'Ranting B'];

  @override
  void onInit() {
    super.onInit();
    fetchDonasi();
    checkPimpinanStatus();
  }

  /// Mengecek apakah user memiliki role pimpinan (wilayah/daerah/cabang/ranting)
  Future<void> checkPimpinanStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Ambil profile dan join ke tabel role
      final response = await _supabase
          .from('profiles')
          .select('role:role_id (tipe)')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['role'] != null) {
        String tipeRole = response['role']['tipe'].toString().toLowerCase();
        
        // Cek apakah mengandung kata kunci wilayah, daerah, cabang, atau ranting
        if (tipeRole.contains('wilayah') || 
            tipeRole.contains('daerah') || 
            tipeRole.contains('cabang') || 
            tipeRole.contains('ranting')) {
          isPimpinan.value = true;
        }
      }
    } catch (e) {
      print("Error checking pimpinan status: $e");
    }
  }

  /// Mengambil semua data donasi dari Supabase
  Future<void> fetchDonasi() async {
    try {
      loading.value = true;

      // Select donasi dan join ke tabel profiles untuk info pembuat
      final response = await _supabase
          .from('donasi_rk')
          .select('*, profiles(wilayah_id, daerah_id, cabang_id, ranting_id)')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> data =
      List<Map<String, dynamic>>.from(response);

      donasiList.assignAll(data);
      searchResults.assignAll(data); // Default tampilkan semua

    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data donasi: $e");
      print(e);
    } finally {
      loading.value = false;
    }
  }

  /// LOGIC 1: Menentukan Alur (Fixed atau Input)
  void processPayment(Map<String, dynamic> data) {
    // Cek Auth
    if (_supabase.auth.currentUser == null) {
      Get.snackbar("Akses Ditolak", "Silakan login terlebih dahulu",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    bool isFix = data['fix_amount'] ?? false;

    if (isFix) {
      // Jalur A: Nominal Fix -> Langsung Bayar
      double amount = double.tryParse(data['nominal'].toString()) ?? 0;
      _executePaymentToApi(data['id'], amount, data['nama']);
    } else {
      // Jalur B: Nominal Bebas -> Panggil Modal UI
      Get.dialog(
        DonasiNominalDialog_view(
          namaDonasi: data['nama'],
          onNominalSubmitted: (inputAmount) {
            // Logic dijalankan setelah user submit modal
            _executePaymentToApi(data['id'], inputAmount, data['nama']);
          },
        ),
      );
    }
  }

  /// LOGIC 2: Komunikasi ke API / Edge Function
  Future<void> _executePaymentToApi(String donasiId, double amount, String donasiNama) async {
    try {
      // Tampilkan Loading Indicator standard GetX
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _supabase.functions.invoke(
        'xendit-payment',
        body: {
          'donasi_id': donasiId,
          'input_amount': amount,
          'description': "Donasi: $donasiNama",
        },
      );

      Get.back(); // Tutup Loading

      final resData = response.data;
      if (resData['error'] != null) throw resData['error'];

      // Navigasi ke WebView
      if (resData['invoice_url'] != null) {
        Get.to(() => XenditWebView_view(url: resData['invoice_url']));
      }

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Safety close loading
      Get.snackbar("Gagal", "Error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }



  /// Logika Filter & Search Client-Side
  void updateFiltersAndSearch({
    String? query,
    String? wilayah,
    String? daerah,
    String? cabang,
    String? ranting,
  }) {
    // Update State
    if (query != null) searchQuery.value = query;
    selectedWilayah.value = wilayah;
    selectedDaerah.value = daerah;
    selectedCabang.value = cabang;
    selectedRanting.value = ranting;

    // Lakukan Filtering pada list lokal
    var temp = donasiList.toList();

    // 1. Filter Search Text
    if (searchQuery.isNotEmpty) {
      temp = temp.where((item) =>
          item['nama'].toString().toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // 2. Filter Wilayah/Daerah (Logic disesuaikan dengan data profiles)
    // Disini saya contohkan filter sederhana, Anda bisa sesuaikan dengan logika ID
    // if (selectedWilayah.value != null) { ... }

    searchResults.assignAll(temp);
  }
}