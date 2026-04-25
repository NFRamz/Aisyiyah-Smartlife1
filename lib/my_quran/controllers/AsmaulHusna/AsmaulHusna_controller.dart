import 'dart:convert';
import 'dart:io'; // Penting untuk GZipCodec
import 'package:flutter/services.dart'; // Untuk rootBundle
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/AsmaulHusna/AsmaulHusna_model.dart';

class AsmaulHusna_controller extends GetxController {
  // Data Asli (Master)
  var allAsmaulHusna = <AsmaulHusna>[];

  // Data yang ditampilkan (bisa berubah saat search)
  var displayedData = <AsmaulHusna>[].obs;

  var isLoading = true.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDataLocal();
  }

  Future<void> loadDataLocal() async {
    try {
      isLoading(true);

      // 1. Load file sebagai ByteData (Biner), BUKAN String
      final ByteData data = await rootBundle.load('assets/data/MyQuran/AsmaulHusna/asmaul_husna.json.gz');

      // 2. Ubah ke List<int>
      List<int> bytes = data.buffer.asUint8List();

      // 3. Decompress GZIP (Ekstrak file)
      List<int> decompressedBytes = GZipCodec().decode(bytes);

      // 4. Decode hasil ekstraksi menjadi String UTF-8
      String jsonString = utf8.decode(decompressedBytes);

      // 5. Parse JSON seperti biasa
      final jsonData = json.decode(jsonString);

      if (jsonData['data'] != null) {
        List<dynamic> listData = jsonData['data'];
        allAsmaulHusna = listData.map((e) => AsmaulHusna.fromJson(e)).toList();

        // Awalnya tampilkan semua
        displayedData.assignAll(allAsmaulHusna);
      }
    } catch (e) {
      print("Error loading Asmaul Husna");
      Get.snackbar("Error", "Gagal memuat data Asmaul Husna");
    } finally {
      isLoading(false);
    }
  }

  void searchAsmaulHusna(String query) {
    if (query.isEmpty) {
      displayedData.assignAll(allAsmaulHusna);
    } else {
      var result = allAsmaulHusna.where((item) {
        return item.latin.toLowerCase().contains(query.toLowerCase()) ||
            item.indo.toLowerCase().contains(query.toLowerCase()) ||
            item.id.toString().contains(query);
      }).toList();
      displayedData.assignAll(result);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}