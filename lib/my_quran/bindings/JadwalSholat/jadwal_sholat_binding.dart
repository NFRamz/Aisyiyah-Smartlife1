
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/JadwalSholat/JadwalSholat_controller.dart';
import 'package:get/get.dart';

class JadwalSholat_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalSholat_controller>(
          () => JadwalSholat_controller(),
    );
  }
}