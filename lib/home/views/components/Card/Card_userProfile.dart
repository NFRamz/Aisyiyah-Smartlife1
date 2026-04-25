import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aisyiyah_smartlife/components/card/user_profile_card.dart';
import 'package:get_storage/get_storage.dart';

Widget Card_userProfile(dynamic controller) {
  return Obx(() {
    final userData = controller.userData.value;
    if (userData == null) return const SizedBox();
    return UserProfileCard(name: userData['nama_pengguna']??"Guest", role: userData['role'] ?? '', location: controller.displayLocationTo_UserProfileCard, profilePicUrl: userData['foto_profile']);
  });
}