
import 'package:aisyiyah_smartlife/modules/donasi/views/Donasi_view.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';

import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:get/get.dart';


import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/components/button/Button_menuIcon.dart';

Widget Button_featureMenuHome(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 10),
      SizedBox(
        height: 110,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double itemWidth          = constraints.maxWidth > 600 ? constraints.maxWidth / 8.8 : constraints.maxWidth / 9.8;
              double padding_horizontal = constraints.maxWidth > 600 ? constraints.maxWidth / 25  : constraints.maxWidth / 56;

              return ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding_horizontal),
                children: [
                  Button_menuIcon('Jadwal Kegiatan', const Icon(Icons.calendar_month_outlined,  color: AppColors.font_green_1, size: 30),  () => Get.toNamed(Routes.JADWALKEGIATAN),  itemWidth),
                  Button_menuIcon("My Qur'an",       const Icon(FlutterIslamicIcons.solidQuran, color: AppColors.font_green_1, size: 30),  () => Get.toNamed(Routes.MY_QURAN),        itemWidth),
                  Button_menuIcon('UMKM',            const Icon(Icons.store,                    color: AppColors.font_green_1, size: 30),  () => Get.toNamed(Routes.UMKM),            itemWidth),
                  Button_menuIcon('Donasi',          const Icon(Icons.card_giftcard,            color: AppColors.font_green_1, size: 30),  () => Get.toNamed(Routes.DONASI),          itemWidth),
              ],
              );
            }
        ),
      ),
    ],
  );
}