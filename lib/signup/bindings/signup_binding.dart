import 'package:aisyiyah_smartlife/modules/signup/controllers/signup_controller.dart';
import 'package:get/get.dart';


class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUp_controller>(
          () => SignUp_controller(),
    );
  }
}