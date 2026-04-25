
import 'package:aisyiyah_smartlife/modules/my_quran/models/Ensiklopedi%20Hadist/HadistDetail_model.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/service/EnsiklopediaHadist_service.dart';
import 'package:get/get.dart';

class HadistDetail_controller extends GetxController {
  final EnsiklopediaHadist_service _service = EnsiklopediaHadist_service();
  final String hadithId;

  var detail = Rxn<HadistDetail_model>();
  var isLoading = true.obs;

  HadistDetail_controller({required this.hadithId});

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  void fetchDetail() async {
    try {
      isLoading(true);
      detail.value = await _service.getHadithDetail(hadithId);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat detail");
    } finally {
      isLoading(false);
    }
  }
}