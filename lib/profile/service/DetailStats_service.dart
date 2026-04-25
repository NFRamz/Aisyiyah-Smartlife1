import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DetailStats_service {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchListItems(String targetType) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Memanggil RPC get_detail_list
      final List<dynamic> response = await supabase.rpc(
        'get_detail_list',
        params: {
          'request_user_id': user.id,
          'target_type': targetType,
        },
      );

      // Casting dynamic list ke List<Map>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception("Gagal mengambil data: $e");
    }
  }
}