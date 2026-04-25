import 'package:aisyiyah_smartlife/modules/splash_screen/controllers/splashscreen_controller.dart';
import 'package:get/get.dart';

class Splashscreen_binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Splashscreen_controller>(
          () => Splashscreen_controller(),
    );
  }
}
