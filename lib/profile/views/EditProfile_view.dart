import 'dart:io';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/profile/controllers/EditProfile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah di-put di binding atau gunakan Get.put
    // Get.put(EditProfileController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: AppColors.font_green_1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.firstNameC.text.isEmpty) {
          // Loading awal saat fetch data profil
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // A. Foto Profil
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      ImageProvider? imageProvider;
                      if (controller.imagePath.value.isNotEmpty) {
                        imageProvider = FileImage(File(controller.imagePath.value));
                      }
                      else if (controller.currentPhotoUrl.value.isNotEmpty) {
                        imageProvider = NetworkImage(controller.currentPhotoUrl.value);
                      }
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.blue, width: 2),
                          image: imageProvider != null
                              ? DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                          )
                              : null,
                        ),
                        child: imageProvider == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: controller.pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.font_green_1, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // B. Data Diri
              _buildTextField("Nama Depan", controller.firstNameC),
              _buildTextField("Nama Belakang", controller.lastNameC),
              _buildTextField("Email", controller.emailC, hint: "Email akan butuh verifikasi ulang jika diubah"),
              _buildTextField("Nomor Telepon", controller.phoneC, isNumber: true),

              const Divider(height: 40),

              // E. Ganti Password
              Text("Ganti Password (Opsional)",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 10),

              _buildTextField("Password Lama", controller.oldPassC, isObscure: true, hint: "Wajib diisi jika ingin ganti password"),
              _buildTextField("Password Baru", controller.newPassC, isObscure: true, hint: "Min 6 karakter, Huruf & Angka"),

              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.font_green_1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: controller.isLoading.value ? null : controller.saveProfile,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // Helper untuk menampilkan gambar (File Lokal atau URL)
  DecorationImage? _getImageProvider() {
    if (controller.imagePath.value.isNotEmpty) {
      return DecorationImage(image: FileImage(File(controller.imagePath.value)), fit: BoxFit.cover);
    }
    // Menggunakan user data dari home controller sebagai fallback visual jika belum upload baru
    String? url = controller.homeController.userData.value?['foto_profile'];
    // Atau bisa pakai variabel _currentPhotoUrl dari controller jika diekspos

    if (url != null && url.isNotEmpty) {
      return DecorationImage(image: NetworkImage(url), fit: BoxFit.cover);
    }
    return null;
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isObscure = false, String? hint, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            obscureText: isObscure,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}