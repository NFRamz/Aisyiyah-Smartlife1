import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/BacaQuran/BacaQuran_controller.dart';

class QuranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BacaQuran_controller>(() => BacaQuran_controller());
  }
}