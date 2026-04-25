import 'package:aisyiyah_smartlife/components/button/Button_PrimaryButton.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/home/controllers/home_controller.dart';
import 'package:aisyiyah_smartlife/modules/home/views/components/Card/Card_userProfile.dart';
import 'package:aisyiyah_smartlife/modules/profile/controllers/Profile_controller.dart';
import 'package:aisyiyah_smartlife/modules/profile/views/components/LayananCard.dart';
import 'package:aisyiyah_smartlife/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileView extends GetView<Profile_controller> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {

    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.cream_3,
      appBar: AppBar(
        backgroundColor: AppColors.font_green_1,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Get.toNamed(Routes.PROFILE_EDIT);
            },
          )
        ],
      ),
      body:GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe kiri → velocity negatif
          if (details.primaryVelocity! > 200) {
            Get.toNamed(Routes.HOME);
          }},
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Point 1: Card User Profile (Reuse Code)
              Card_userProfile(homeController),

              const SizedBox(height: 25),

              // Point 2: Grid Info Statistik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  if (controller.statsList.isEmpty) {
                    return const SizedBox.shrink(); // Anggota biasa / Loading / Data kosong
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.3, // Membuat aspek rasio agak persegi panjang/persegi
                        ),
                        itemCount: controller.statsList.length,
                        itemBuilder: (context, index) {
                          final stat = controller.statsList[index];
                          return _buildStatCard(
                            title: stat['title'],
                            count: stat['count'].toString(),
                            showArrow: stat['showArrow'],
                            onTap: () {
                              if (stat['showArrow']) {
                                Get.toNamed(Routes.PROFILE_DETAIL,
                                    arguments: {
                                      'title': stat['title'],
                                      'type': stat['type']
                                    });
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 25),

              // 3. LAYANAN & KONTAK SECTION (Accordion)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                // BUNGKUS Column DI BAWAH INI DENGAN OBX
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Karena dibungkus Obx, saat list di controller berubah,
                    // fungsi _buildLayananGroup akan dipanggil ulang otomatis.
                    _buildLayananGroup("Layanan dari Wilayah", controller.layananWilayahList),
                    _buildLayananGroup("Layanan dari Daerah", controller.layananDaerahList),
                    _buildLayananGroup("Layanan dari Cabang", controller.layananCabangList),
                    _buildLayananGroup("Layanan dari Ranting", controller.layananRantingList),
                  ],
                )),
              ),

              const SizedBox(height: 30),
              // Point 4: Tombol Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => PrimaryButton(
                  isLoading: controller.isLoading.value,
                  onTap: controller.handleLogout,
                  warna: AppColors.font_green_1, // Atau Colors.redAccent untuk logout biasanya
                  text: "Keluar",
                  animasi: Curves.easeInOut,
                )),
              ),
              const SizedBox(height:20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(
                      "https://docs.google.com/forms/d/e/1FAIpQLSeca4Ex_ztoYbaXrl_xplHfMLLUE0-xb_qHz8GqgjHaSw3dRA/viewform?usp=header"
                  );

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  "Ada Kritik,Saran,Kendala? Klik Disini",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],

          ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      )
    );
  }

  //for point 2
  Widget _buildStatCard({
    required String title,
    required String count,
    required bool showArrow,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: showArrow ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: AppColors.font_green_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showArrow)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.font_green_1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.font_green_1,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLayananGroup(String title, List<Map<String, dynamic>> dataList) {
    if (dataList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return LayananCard(data: dataList[index]);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}




