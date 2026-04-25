import 'package:aisyiyah_smartlife/modules/profile/service/DetailStats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class DetailStats_controller extends GetxController {
  final DetailStats_service _service = DetailStats_service();

  // Argument yang diterima dari halaman Profile
  late String titlePage;
  late String targetType; // 'daerah', 'cabang', 'ranting', 'anggota'

  var isLoading = true.obs;
  var listData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Mengambil argumen dari Get.toNamed
    // Contoh call: Get.toNamed('/detail-list', arguments: {'title': 'Total Cabang', 'type': 'cabang'});
    final args = Get.arguments as Map<String, dynamic>;
    titlePage = args['title'] ?? 'Detail Informasi';
    targetType = args['type'] ?? '';

    fetchData();
  }

  void fetchData() async {
    try {
      isLoading(true);
      final result = await _service.fetchListItems(targetType);
      listData.assignAll(result);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA COPY & SHARE ---

  // Membuat format text rapi untuk WhatsApp
  String _generateShareText() {
    StringBuffer buffer = StringBuffer();
    // Header Bold (Format WA menggunakan *)
    buffer.writeln("*LAPORAN DATA ${targetType.toUpperCase()}*");
    buffer.writeln("Total: ${listData.length}");
    buffer.writeln("--------------------------------");

    int index = 1;
    for (var item in listData) {
      String nama = item['nama_item'] ?? '-';
      // Jika ada lokasi/info tambahan, bisa ditampilkan dalam kurung
      // String lokasi = item['lokasi_item'] ?? '';
      buffer.writeln("$index. $nama");
      index++;
    }

    buffer.writeln("--------------------------------");
    buffer.writeln("Dicetak via Aplikasi Aisyiyah SmartLife");

    return buffer.toString();
  }

  void copyToClipboard() {
    if (listData.isEmpty) return;
    String text = _generateShareText();
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
        "Disalin",
        "Data berhasil disalin ke clipboard",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1)
    );
  }

  void shareToApps() {
    if (listData.isEmpty) return;
    String text = _generateShareText();
    Share.share(text, subject: "Data $titlePage");
  }
}