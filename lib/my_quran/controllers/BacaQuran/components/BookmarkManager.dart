import 'dart:ui';

import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/AyatModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/components/SurahModel.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/views/BacaQuran/QuranDetail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

mixin BookmarkManager on GetxController{

  final boxStorage    = GetStorage();
  var bookmarks       = <Map<String, dynamic>>[].obs;
  var selectedFolder  = 'Semua'.obs;
  var folderList      = <String>["Umum", "Hafalan", "Favorit"].obs;
  RxList<Surah> get listSurah;
  void fetchDetailSurah(Surah surah);


  void openBookmarkList() {
    // Reset filter ke "Semua" saat pertama buka
    selectedFolder.value = "Semua";

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7, // Tinggi sheet 70% layar
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Indikator geser
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Daftar Bookmark", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.font_green_1)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Folder Baru"),
                    onPressed: () => showCreateFolderDialog(),
                    style: TextButton.styleFrom(foregroundColor: AppColors.font_green_1),
                  )
                ],
              ),
            ),

            // 1. FILTER FOLDER (Horizontal List)
            SizedBox(
              height: 50,
              child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Chip "Semua"
                  buildFolderChip("Semua"),
                  // Chip folder lain dari controller
                  ...folderList.map((folder) => buildFolderChip(folder)).toList(),
                ],
              )),
            ),

            const Divider(),

            // 2. LIST BOOKMARK
            Expanded(
              child: Obx(() {
                // Filter list berdasarkan folder yang dipilih
                var filteredList = bookmarks.where((item) {
                  if (selectedFolder.value == "Semua") return true;
                  return item['folder'] == selectedFolder.value;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text("Kosong di folder '${selectedFolder.value}'", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredList.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    var item = filteredList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.font_green_1.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.bookmark, color: AppColors.font_green_1),
                      ),
                      title: Text("Surah ${item['surah_nama']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ayat ${item['ayat_nomor']}"),
                          // Tampilkan label folder kecil jika sedang di tab "Semua"
                          if(selectedFolder.value == "Semua")
                            Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                              child: Text(item['folder'] ?? 'Umum', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            )
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => deleteBookmark(item['verse_key']),
                      ),
                      onTap: () {
                        // LOGIKA NAVIGASI (FIX)
                        try {
                          var targetSurah = listSurah.firstWhere((s) => s.number == item['surah_nomor']);
                          fetchDetailSurah(targetSurah);

                          // Hitung index untuk scroll (ayat_nomor - 1)
                          int jumpIndex = item['ayat_nomor'];

                          Get.back(); // Tutup bottom sheet dulu
                          Get.to(() => QuranDetailView(surah: targetSurah, jumpToAyatIndex: jumpIndex));
                        } catch (e) {
                          Get.snackbar("Error", "Surah tidak ditemukan");
                        }
                      },
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  void loadBookmarks() {
    var data = boxStorage.read('bookmarks');
    var savedFolders = boxStorage.read('folders');
    if (data != null) {
      bookmarks.assignAll(List<Map<String, dynamic>>.from(data));
      if (savedFolders != null) {
        var loaded = List<String>.from(savedFolders);
        for (var f in loaded) {
          if (!folderList.contains(f)) folderList.add(f);
        }
      }

    }

  }

  bool isBookmarked(String verseKey) {
    return bookmarks.any((element) => element['verse_key'] == verseKey);
  }

  void addBookmark(Surah surah, Ayat ayat, String folderName) {
    Map<String, dynamic> data = {
      'surah_nama'  : surah.nameId,
      'surah_nomor' : surah.number,
      'ayat_nomor'  : ayat.ayahNumber,
      'verse_key'   : ayat.id,
      'folder'      : folderName,
    };

    // Hapus bookmark lama di ayat yang sama (agar tidak duplikat/update folder)
    bookmarks.removeWhere((e) => e['verse_key'] == ayat.id);

    bookmarks.add(data);
    boxStorage.write('bookmarks', bookmarks.toList());

    Get.back();
    Get.snackbar("Tersimpan", "Ayat disimpan ke folder $folderName", snackPosition: SnackPosition.TOP, backgroundColor: AppColors.font_green_1, colorText: Colors.white);}

  void deleteBookmark(String verseKey) {
    bookmarks.removeWhere((element) => element['verse_key'] == verseKey);
    boxStorage.write('bookmarks', bookmarks.toList());
  }

  void toggleBookmark(Surah surah, Ayat ayat) {
    if (isBookmarked(ayat.id)) {
      deleteBookmark(ayat.id);
    } else {
      addBookmark(surah, ayat, "Umum");
    }
  }

  void createFolder(String folderName) {
    if (!folderList.contains(folderName)) {
      folderList.add(folderName);
      boxStorage.write('folders', folderList.toList());
      Get.snackbar("Sukses", "Folder $folderName dibuat", snackPosition: SnackPosition.TOP, backgroundColor: AppColors.font_green_1, colorText: Colors.white);
    }
  }

  void deleteFolder(String folderName) {
    if (folderName == "Umum") {
      Get.snackbar("Gagal", "Folder utama 'Umum' tidak dapat dihapus", snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (folderList.contains(folderName)) {
      folderList.remove(folderName);
      boxStorage.write('folders', folderList.toList());

      // memindahkan bookmark yang ada di folder ini ke "Umum"
      bool hasChanges = false;
      for (var item in bookmarks) {
        if (item['folder'] == folderName) {
          item['folder']  = 'Umum';
          hasChanges      = true;
        }
      }

      if (hasChanges) {
        bookmarks.refresh();
        boxStorage.write('bookmarks', bookmarks.toList());
      }
      if (selectedFolder.value == folderName) {
        selectedFolder.value = 'Semua';
      }

      Get.snackbar("Terhapus", "Folder dihapus, isi dipindah ke Umum", snackPosition: SnackPosition.TOP, backgroundColor: Colors.black87, colorText: Colors.white);
    }
  }

  Widget buildFolderChip(String folderName) {
    bool isSelected = selectedFolder.value == folderName;

    // Tentukan apakah folder ini boleh dihapus atau tidak
    // "Semua" adalah filter tampilan, "Umum" adalah folder default sistem
    bool canDelete = folderName != "Semua" && folderName != "Umum";

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        // FITUR BARU: Tekan tahan untuk hapus
        onLongPress: () {
          if (canDelete) {
            showDeleteFolderDialog(folderName);
          } else {
            Get.snackbar("Info", "Folder '$folderName' tidak dapat dihapus", snackPosition: SnackPosition.BOTTOM);
          }
        },
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(folderName),
              // Opsional: Tampilkan indikator kecil jika folder bisa dihapus (agar user tahu)
              if (isSelected && canDelete) ...[
                const SizedBox(width: 4),
                // const Icon(Icons.close, size: 14, color: Colors.white) // Opsional
              ]
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) selectedFolder.value = folderName;
          },
          selectedColor: AppColors.font_green_1,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          backgroundColor: Colors.white,
          shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
        ),
      ),
    );
  }

  void showDeleteFolderDialog(String folderName) {
    Get.defaultDialog(
        title: "Hapus Folder?",
        titleStyle: TextStyle(color: AppColors.font_green_1, fontWeight: FontWeight.bold),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text("Anda akan menghapus folder '$folderName'.", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                "Bookmark di dalam folder ini TIDAK akan hilang, tetapi akan dipindahkan ke folder 'Umum'.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        textConfirm: "Hapus",
        textCancel: "Batal",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent, // Warna merah untuk aksi destruktif
        cancelTextColor: Colors.black87,
        onConfirm: () {
          deleteFolder(folderName); // Panggil fungsi di controller
          Get.back(); // Tutup dialog
        }
    );
  }

  void showCreateFolderDialog() {
    TextEditingController textC = TextEditingController();
    Get.defaultDialog(
        title: "Folder Baru",
        content: TextField(
          controller: textC,
          decoration: const InputDecoration(hintText: "Nama folder (cth: Hafalan)"),
        ),
        textConfirm: "Simpan",
        textCancel: "Batal",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.font_green_1,
        onConfirm: () {
          if(textC.text.isNotEmpty) {
            createFolder(textC.text);
            Get.back();
          }
        }
    );
  }
}