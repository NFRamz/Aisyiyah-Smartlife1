import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:get/get.dart';

class JadwalKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalKegiatanController>(
          () => JadwalKegiatanController(),
    );
  }
}