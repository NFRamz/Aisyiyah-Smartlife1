import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/DetailKegiatan_controller.dart';
import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/jadwal_kegiatan_controller.dart';
import 'package:get/get.dart';

class DetailKegiatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKegiatanController>(
          () => DetailKegiatanController(),
    );
  }
}