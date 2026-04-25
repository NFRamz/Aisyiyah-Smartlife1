import 'package:aisyiyah_smartlife/modules/my_quran/controllers/QuranAudioPlayer/QuranAudioDownloader_controller.dart';
import 'package:get/get.dart';

class QuranAudioDownloader_bindings extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut<QuranAudioDownloader_controller>(
          () => QuranAudioDownloader_controller(),
    );
  }
}
