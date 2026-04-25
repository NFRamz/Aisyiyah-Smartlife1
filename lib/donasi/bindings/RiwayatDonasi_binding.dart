import 'package:aisyiyah_smartlife/modules/donasi/controllers/RiwayatDonasi_controller.dart';
import 'package:get/get.dart';

class RiwayatDonasi_binding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<RiwayatDonasi_controller>(
          () => RiwayatDonasi_controller(),
    );
  }

}