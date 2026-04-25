import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';

class KegiatanModal_controller extends GetxController {
  // Dependencies
  final JadwalKegiatanController parentController;
  final KegiatanModel? item;

  KegiatanModal_controller({required this.parentController, this.item});

  // Text Controllers
  late TextEditingController namaController;
  late TextEditingController deskripsiController;
  late TextEditingController lokasiController;
  late TextEditingController mapsController;

  // Reactive Variables (State)
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;

  // Logic Saklar & Jadwal
  var scheduleDate = DateTime.now().obs;
  var scheduleTime = TimeOfDay.now().obs;
  var selectedFrequency = 'none'.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi Text Controllers
    namaController = TextEditingController(text: item?.nama);
    deskripsiController = TextEditingController(text: item?.deskripsi);
    lokasiController = TextEditingController(text: item?.lokasi);
    mapsController = TextEditingController(text: item?.googleMapsLink);

    // Inisialisasi Data Waktu & Pilihan
    selectedDate.value = item?.tanggal ?? DateTime.now();
    selectedTime.value = TimeOfDay.fromDateTime(selectedDate.value);

    selectedFrequency.value = item?.frekuensiUlang ?? 'none';

  }

  @override
  void onClose() {
    namaController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    mapsController.dispose();
    super.onClose();
  }

  // --- Actions ---

  void deleteItem() {
    if (item != null) {
      Get.defaultDialog(
          title: "Hapus",
          middleText: "Hapus kegiatan ini?",
          textConfirm: "Ya",
          textCancel: "Batal",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Tutup Dialog Konfirmasi
            Get.back(); // Tutup Modal View
            parentController.deleteKegiatan(item!);
          }
      );
    }
  }

  void saveItem() {
    if (namaController.text.isEmpty) {
      Get.snackbar("Error", "Nama wajib diisi", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Gabungkan Date + Time untuk Waktu Pelaksanaan
    final combinedDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );


    if (item != null) {
      // Update
      parentController.updateKegiatan(
        item!,
        namaController.text,
        combinedDateTime,
        deskripsiController.text,
        cleanMapsUrl(mapsController.text),
        lokasiController.text,
        selectedFrequency.value,
      );
    } else {
      // Create New
      parentController.addKegiatan(
        namaController.text,
        combinedDateTime,
        deskripsiController.text,
        cleanMapsUrl(mapsController.text),
        lokasiController.text,
        selectedFrequency.value,
      );
    }
  }

  String? cleanMapsUrl(String? input) {
    if (input == null || input.isEmpty) return null;
    final RegExp urlRegExp = RegExp(r'https?://\S+');
    final match = urlRegExp.firstMatch(input);
    return match?.group(0) ?? input;
  }
}