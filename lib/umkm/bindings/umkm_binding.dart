import 'package:get/get.dart';
import '../controllers/umkm_controller.dart';

class UmkmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UmkmController>(() => UmkmController());
  }
}
