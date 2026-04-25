import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/AsmaulHusna/AsmaulHusna_controller.dart';

class AsmaulHusna_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsmaulHusna_controller>(() => AsmaulHusna_controller());
  }
}