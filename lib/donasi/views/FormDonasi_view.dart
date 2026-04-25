import 'package:aisyiyah_smartlife/core/values/AppColors.dart';
import 'package:aisyiyah_smartlife/modules/donasi/controllers/FormDonasi_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class FormDonasi_view extends StatelessWidget {
  const FormDonasi_view({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Get.put agar controller diinisialisasi ulang setiap halaman dibuka
    final controller = Get.put(FormDonasi_controller());
    final isEdit = controller.editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Program Donasi' : 'Tambah Program Donasi',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.green_1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Section
            Text("Gambar Program", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPickerSheet(controller),
              child: Obx(() {
                final file = controller.selectedImage.value;
                final url = controller.currentImageUrl.value;

                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: file != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover))
                      : (url.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image),))
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  Text("Upload Foto", style: GoogleFonts.poppins(color: Colors.grey)),
                                ],
                              ),
                            )),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Form Fields
            _buildTextField("Nama Program", "Masukkan nama donasi...", controller.namaController),
            const SizedBox(height: 16),
            
            Text("Tipe Nominal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            Obx(() => SwitchListTile(
                  title: Text(
                    controller.fixAmount.value ? "Nominal Tetap (Fix Amount)" : "Nominal Bebas",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  value: controller.fixAmount.value,
                  activeColor: AppColors.green_1,
                  onChanged: (val) => controller.fixAmount.value = val,
                )),
            
            Obx(() => controller.fixAmount.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTextField("Nominal (Rp)", "Contoh: 50000", controller.nominalController, keyboardType: TextInputType.number),
                  )
                : const SizedBox.shrink()),

            _buildTextField("Deskripsi", "Deskripsi lengkap program donasi...", controller.deskripsiController, maxLines: 5),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.saveDonasi(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green_1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Obx(() => controller.isLoading.value
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                    : Text(
                        isEdit ? 'Update Program' : 'Simpan Program',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.green_1),
            ),
          ),
        ),
      ],
    );
  }

  void _showPickerSheet(FormDonasi_controller controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
