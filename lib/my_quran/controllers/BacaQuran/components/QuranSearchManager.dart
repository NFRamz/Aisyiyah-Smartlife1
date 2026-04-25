import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/AyatModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/SurahModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

mixin QuranSearchManager on GetxController{
  //abstrac getter karna variabel di class lain(quranservice)
  RxList<Surah> get listSurah;

  TextEditingController searchController = TextEditingController();
  var selectedKategori = RxnString();
  var searchText = ''.obs;

  List<dynamic> get filteredSurahList {
    // 1. Ambil list asli
    var results = listSurah.toList();

    // 2. Filter Search (Nama Latin)
    if (searchText.value.isNotEmpty) {
      results = results.where((surah) {
        return surah.nameId.toLowerCase().contains(searchText.value.toLowerCase());
      }).toList();
    }

    // 3. Filter Kategori (Mekah/Madinah)
    // Menggunakan selectedKategori yang baru (nullable)
    if (selectedKategori.value != null) {
      results = results.where((surah) {
        // Pastikan case-insensitive
        return surah.revelation.toString().toLowerCase() == selectedKategori.value!.toLowerCase();
      }).toList();
    }

    return results;
  }

  String getCombinedLatin(Ayat ayat) {
    if (ayat.words.isEmpty) return "";

    return ayat.words
    // Filter: hanya ambil yang tipe 'word', jangan 'end' (tanda ayat)
        .where((w) => w.charTypeName == 'word')
    // Di Model, 'translation' berisi teks latin/transliterasi
        .map((w) => w.translation)
        .where((text) => text.isNotEmpty)
        .join(" ");
  }

}