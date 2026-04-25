import 'package:aisyiyah_smartlife/modules/jadwalKegiatan/controllers/ExportExcelController.dart';
import 'package:get/get.dart';


class ExportExcelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExportExcelController>(
          () => ExportExcelController(),
    );
  }
}