import 'package:aisyiyah_smartlife/modules/profile/controllers/Profile_controller.dart';

import 'package:get/get.dart';


class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Profile_controller>(() => Profile_controller());
  }
}