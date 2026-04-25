import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/controllers/MyQuran_controller.dart'; // Sesuaikan path import

class MyQuranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyQuranController>(() => MyQuranController());
  }
}