import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailUmkmController extends GetxController {
  final supabase = Supabase.instance.client;

  var data = Rxn<Map<String, dynamic>>();
  var loading = true.obs;

  late String id;

  @override
  void onInit() {
    super.onInit();
    id = Get.parameters['id'] ?? "";
    loadDetail();
  }

  Future<void> loadDetail() async {
    final res = await supabase
        .from('umkm')
        .select('*, maps_link')
        .eq('id', id)
        .maybeSingle();

    data.value = res;
    loading.value = false;
  }
}
