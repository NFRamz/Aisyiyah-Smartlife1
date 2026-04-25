import 'package:aisyiyah_smartlife/modules/donasi/controllers/Donasi_controller.dart';
import 'package:get/get.dart';

class Donasi_binding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<Donasi_controller>(
        () => Donasi_controller(),
    );
  }

}