import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:alarm/alarm.dart';


import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/models/KegiatanModel.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';

class AlarmModalController extends GetxController {
  final JadwalKegiatanController _mainController = Get.find<JadwalKegiatanController>();

  // --- STATE UI (Observables) ---
  var selectedKegiatan = Rxn<KegiatanModel>();
  var minutesBefore    = 60.obs;
  var isCustomTime     = false.obs;

  late TextEditingController customTimeController;

  @override
  void onInit() {
    super.onInit();
    customTimeController = TextEditingController();
    // Alarm.init() sudah dipanggil di main.dart
  }

  // --- GETTER & HELPER (Sama seperti sebelumnya) ---
  List<KegiatanModel> get upcomingEvents {
    return _mainController.displayedKegiatan
        .where((k) => k.tanggal.isAfter(DateTime.now()))
        .toList();
  }

  void setTime(int minutes) {
    isCustomTime.value = false;
    minutesBefore.value = minutes;
  }

  void toggleCustomTime(bool? val) => isCustomTime.value = val ?? false;

  void updateCustomTime(String val) {
    if (val.isNotEmpty) minutesBefore.value = int.tryParse(val) ?? 60;
  }

  // --- LOGIC UTAMA (ALARM) ---
  Future<void> setReminder() async {
    final kegiatan = selectedKegiatan.value;

    if (kegiatan == null) {
      Get.snackbar("Error", "Pilih kegiatan terlebih dahulu");
      return;
    }

    // 1. Hitung waktu alarm
    final eventDate = kegiatan.tanggal;
    final reminderDate = eventDate.subtract(Duration(minutes: minutesBefore.value));


    if (reminderDate.isBefore(DateTime.now())) {
      Get.snackbar("Gagal", "Waktu alarm sudah terlewat.");
      return;
    }

    // 2. Buat ID Unik (Harus Integer)

    final alarmId = kegiatan.id.hashCode.abs();

    // 3. Konfigurasi Alarm
    // Pastikan Anda punya file audio di assets, misal: assets/audio/alarm.mp3
    // Dan daftarkan di pubspec.yaml
    final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: reminderDate,
        assetAudioPath: 'assets/audio/jadwalKegiatan_sound.mp3',
        loopAudio: true,
        vibrate: true,
        volume: 1.0,
        fadeDuration: 1.0,

        // PERUBAHAN DI SINI:
        // Masukkan title, body, dan tombol stop ke dalam NotificationSettings
        notificationSettings: NotificationSettings(
          title: "Pengingat: ${kegiatan.nama}",
          body: "Kegiatan dimulai dalam ${minutesBefore.value} menit!",
          stopButton: "Matikan Alarm", // Teks untuk tombol stop di notifikasi
          icon: 'notification_icon',   // Opsional: Nama icon di folder drawable (android)
        ));

    try {
      // 4. Set Alarm
      await Alarm.set(alarmSettings: alarmSettings);

      // --- SIMPAN KE GET STORAGE UNTUK SYNC (Opsional) ---
      final box = GetStorage();
      List<dynamic> myAlarms = box.read<List>('my_alarms') ?? [];

      // Bersihkan alarm lama untuk ID yang sama
      myAlarms.removeWhere((element) => element['id'] == kegiatan.id);

      myAlarms.add({
        'id': kegiatan.id,
        'alarmId': alarmId,
        'date': reminderDate.toIso8601String(),
        'eventDate': eventDate.toIso8601String(),
      });
      await box.write('my_alarms', myAlarms);
      // ----------------------------------------------------

      Get.back();
      Get.snackbar(
        "Alarm Diatur",
        "Akan berbunyi pada ${DateFormat('HH:mm, d MMM').format(reminderDate)}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _mainController.addActiveAlarm(kegiatan.id);

    } catch (e) {
      print("Error se");
      Get.snackbar("Error", "Gagal mengatur alarm");
    }
  }

  Future<void> cancelReminder(KegiatanModel kegiatan) async {
    try {
      final alarmId = kegiatan.id.hashCode.abs();

      // Stop Alarm
      await Alarm.stop(alarmId);

      // Hapus dari Storage
      final box = GetStorage();
      List<dynamic> myAlarms = box.read<List>('my_alarms') ?? [];
      myAlarms.removeWhere((element) => element['id'] == kegiatan.id);
      await box.write('my_alarms', myAlarms);

      Get.snackbar("Info", "Alarm dibatalkan");
      _mainController.removeActiveAlarm(kegiatan.id);
    } catch (e) {
      print("123");
    }
  }
}