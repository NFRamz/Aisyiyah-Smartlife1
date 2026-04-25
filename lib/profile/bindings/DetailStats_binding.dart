import 'package:aisyiyah_smartlife/modules/profile/controllers/DetailStats_controller.dart';
import 'package:get/get.dart';

class DetailStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailStats_controller>(() => DetailStats_controller());
  }
}