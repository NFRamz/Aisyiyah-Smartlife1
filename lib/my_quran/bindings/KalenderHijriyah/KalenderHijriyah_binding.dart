import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/KalenderHijriyah/KalenderHijriyah_controller.dart';

class KalenderHijriyah_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KalenderHijriyah_controller>(() => KalenderHijriyah_controller());
  }
}