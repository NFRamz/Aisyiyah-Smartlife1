import 'package:aisyiyah_smartlife/modules/umkm/controllers/KelolaUmkm_controller.dart';
import 'package:get/get.dart';
import '../controllers/umkm_controller.dart';

class KelolaUmkm_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaUmkm_controller>(() => KelolaUmkm_controller());
  }
}
