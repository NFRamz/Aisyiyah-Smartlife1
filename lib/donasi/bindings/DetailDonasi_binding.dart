import 'package:aisyiyah_smartlife/modules/donasi/controllers/DetailDonasi_controller.dart';
import 'package:get/get.dart';

class DetailDonasi_binding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<DetailDonasi_controller>(
          () => DetailDonasi_controller(),
    );
  }

}