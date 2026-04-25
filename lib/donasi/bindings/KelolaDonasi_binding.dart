import 'package:aisyiyah_smartlife/modules/donasi/controllers/KelolaDonasi_controller.dart';
import 'package:get/get.dart';

class KelolaDonasi_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaDonasi_controller>(
      () => KelolaDonasi_controller(),
    );
  }
}
