import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyQuranController extends GetxController {

  // Ubah ke 'true' untuk maintenance, ambil dari API/Firebase
  var isMaintenance = false.obs;

  // Fungsi helper untuk mengeksekusi aksi jika tidak sedang maintenance
  void runAction(Function action) {
    if (isMaintenance.value) {
      Get.snackbar("Sedang Perbaikan", "Fitur ini sedang dalam pengembangan.");
    } else {
      action();
    }
  }
  void appbarNavigate()async{
    final sp = await SharedPreferences.getInstance();
    final isLoggedIn = sp.getBool("isLoggedIn") ?? false;
    final email = sp.getString("email");

    if(isLoggedIn && email != null){
      Get.offAllNamed(Routes.HOME);
    }else if(isLoggedIn){
      sp.clear();
      Get.toNamed(Routes.LOGIN);
    }

  }
}