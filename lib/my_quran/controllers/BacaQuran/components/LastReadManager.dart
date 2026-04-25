import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/BacaQuran/QuranDetail_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

//model
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/AyatModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/SurahModel.dart';

mixin LastReadManager on GetxController{
  RxList<Surah> get listSurah;
  void fetchDetailSurah(Surah surah);


  final boxStorage = GetStorage();
  var lastRead = Rxn<Map<String,dynamic>>();

  void openLastRead() {
    var last = lastRead.value;
    if (last != null && listSurah.isNotEmpty) {
      try {
        var targetSurah = listSurah.firstWhere((s) => s.number == last['surah_nomor']);
        fetchDetailSurah(targetSurah);

        // Fix: Ambil index ayat untuk jump
        int jumpIndex = last['index_ayat'] ?? (last['ayat_nomor'] - 1);

        Get.to(() => QuranDetailView(surah: targetSurah, jumpToAyatIndex: jumpIndex));

      } catch (e) {
        Get.snackbar("Error", "Gagal memuat data surah");
      }
    } else {
      Get.snackbar("Info", "Belum ada riwayat bacaan");
    }
  }

  void loadLastRead() {
    var data = boxStorage.read('last_read');
    if (data != null) lastRead.value = data;
  }

  void saveLastRead(Surah surah, Ayat ayat) {
    Map<String, dynamic> data = {
      'surah_nama'  : surah.nameId,
      'surah_nomor' : surah.number,
      'ayat_nomor'  : ayat.ayahNumber,
      'index_ayat'  : ayat.ayahNumber,
      'verse_key'   : ayat.id,
      'waktu': DateTime.now().toString(),
    };

    boxStorage.write('last_read', data);
    lastRead.value = data;

    Get.snackbar(
        "Ditandai", "Terakhir dibaca disimpan di Ayat ${ayat.ayahNumber}", snackPosition: SnackPosition.TOP, backgroundColor: AppColors.font_green_1, colorText: Colors.white, margin: const EdgeInsets.all(16)
    );
  }
}