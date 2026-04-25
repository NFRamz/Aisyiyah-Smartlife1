import 'package:aisyiyah_smartlife/modules/my_quran/controllers/QuranAudioPlayer/QuranAudioPlayer_controller.dart';
import 'package:get/get.dart';

class QuranAudioPlayer_binding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<QuranAudioPlayer_controller>(
        () => QuranAudioPlayer_controller()
    );
  }
}