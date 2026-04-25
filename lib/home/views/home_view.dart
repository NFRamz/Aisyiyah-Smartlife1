import 'package:aisyiyah_smartlife/modules/home/controllers/home_controller.dart';
import 'package:aisyiyah_smartlife/modules/home/views/components/Button/Button_featureMenuHome.dart';
import 'package:aisyiyah_smartlife/modules/home/views/components/Card/Card_jadwalSection.dart';
import 'package:aisyiyah_smartlife/modules/home/views/components/Card/Card_header.dart';
import 'package:aisyiyah_smartlife/modules/home/views/components/Card/Card_userProfile.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.cream_3,

      body:
      GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe kiri → velocity negatif
          if (details.primaryVelocity! < -200) {
            Get.toNamed(Routes.PROFILE);
          }},
        child:SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshData,
            color: const Color(0xFF4CAF50),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  Card_header(context, controller),
                  const SizedBox(height: 30),
                  Card_userProfile(controller),
                  const SizedBox(height: 30),
                  Button_featureMenuHome(context),
                  const SizedBox(height: 35),
                  Card_jadwalSection(context, controller),
                ],
              );
            }),
          ),
        ),
      )


    );
  }
}