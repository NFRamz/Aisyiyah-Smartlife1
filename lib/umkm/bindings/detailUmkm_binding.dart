import 'package:get/get.dart';
import '../controllers/detailUmkm_controller.dart';

class DetailUmkmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailUmkmController>(() => DetailUmkmController());
  }
}
