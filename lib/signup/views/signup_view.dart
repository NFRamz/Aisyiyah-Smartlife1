import 'package:aisyiyah_smartlife/modules/signup/controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';


class SignUp_view extends GetView<SignUp_controller> {
  const SignUp_view({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream_3,
      appBar: AppBar(
        title: const Text("Registrasi Anggota"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.app_registration, size: 60, color: AppColors.font_green_1),
            const SizedBox(height: 16),
            const Text(
              'Buat Akun Baru',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.font_green_1),
            ),
            const Text(
              'Isi sesuai data yang telah terdaftar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // --- NAMA ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.firstNameController,
                    decoration: const InputDecoration(labelText: 'Nama Depan *', prefixIcon: Icon(Icons.person), ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.lastNameController,
                    decoration: const InputDecoration(labelText: 'Belakang (Opsional)', ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- KONTAK ---
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No. Telepon (Opsional)', prefixIcon: Icon(Icons.phone), ),
            ),
            const SizedBox(height: 16),

            const Divider(),
            const Text("Lokasi Keanggotaan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            // --- CASCADING DROPDOWNS ---

            // 1. WILAYAH (Provinsi)
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedWilayahId.value,
              decoration: const InputDecoration(labelText: 'Wilayah (Provinsi) *', ),
              items: controller.wilayahList.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(item['provinsi'] ?? '-'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.selectedWilayahId.value = val;
                  controller.fetchDaerah(val);
                }
              },
            )),
            const SizedBox(height: 16),

            // 2. DAERAH (Kab/Kota)
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedDaerahId.value,
              decoration: const InputDecoration(labelText: 'Daerah *', ),
              items: controller.daerahList.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(item['daerah'] ?? '-'),
                );
              }).toList(),
              onChanged: (val) {
                controller.selectedDaerahId.value = val;
                if (val != null) controller.fetchCabang(val);
              },
            )),
            const SizedBox(height: 16),

            // 3. CABANG
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCabangId.value,
              decoration: const InputDecoration(labelText: 'Cabang *', ),
              items: controller.cabangList.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(item['cabang'] ?? '-'),
                );
              }).toList(),
              onChanged: (val) {
                controller.selectedCabangId.value = val;
                if (val != null) controller.fetchRanting(val);
              },
            )),
            const SizedBox(height: 16),

            // 4. RANTING
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedRantingId.value,
              decoration: const InputDecoration(labelText: 'Ranting (Opsional)', ),
              items: controller.rantingList.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(item['ranting'] ?? '-'),
                );
              }).toList(),
              onChanged: (val) => controller.selectedRantingId.value = val,
            )),
            const SizedBox(height: 24),

            // --- PASSWORD ---
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password *',
                helperText: 'Min 6 karakter, huruf & angka',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password *',
                prefixIcon: Icon(Icons.lock),

              ),
            ),
            const SizedBox(height: 32),

            // --- BUTTONS ---
            Obx(() {
              return SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.font_green_1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              );
            }),

            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: const Text('Sudah punya akun? Masuk di sini', style: TextStyle(color: AppColors.font_green_1)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}