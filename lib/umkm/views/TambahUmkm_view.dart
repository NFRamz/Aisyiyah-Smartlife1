import 'package:aisyiyah_smartlife/modules/umkm/controllers/TambahUmkm_controller.dart';
import 'package:aisyiyah_smartlife/modules/umkm/model/Umkm_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class TambahUmkm_view extends StatelessWidget {
  final Umkm_model? umkmData;

  TambahUmkm_view({super.key, this.umkmData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FormUmkmController());

    // Inisialisasi data form saat pertama kali build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initFormData(umkmData);
    });

    final isEdit = umkmData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit UMKM' : 'Tambah UMKM',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            Text("Gambar UMKM", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover))
                      : Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      Text("Upload Foto", style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ))),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Text Fields
            _buildTextField("Nama UMKM", "Masukkan nama...", controller.namaController),
            const SizedBox(height: 16),
            _buildTextField("Link Google Maps", "https://maps.google.com/...", controller.mapsLinkController, icon: Icons.map),

            const SizedBox(height: 24),

            // Social Media Section
            Text("Social Media", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            _buildSocialMediaList(controller),

            const SizedBox(height: 24),

            _buildTextField("Deskripsi", "Deskripsi lengkap usaha...", controller.deskripsiController, maxLines: 5),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.saveUmkm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Update Data' : 'Simpan Data', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[700]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaList(FormUmkmController controller) {
    final options = [
      {'key': 'whatsapp', 'label': 'WhatsApp', 'icon': Icons.chat},
      {'key': 'instagram', 'label': 'Instagram', 'icon': Icons.camera_alt},
      {'key': 'facebook', 'label': 'Facebook', 'icon': Icons.facebook},
      {'key': 'tiktok', 'label': 'TikTok', 'icon': Icons.music_note},
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: options.map((opt) {
          final key = opt['key'] as String;
          return Obx(() {
            final isSelected = controller.selectedSocials[key] ?? false;
            return Column(
              children: [
                CheckboxListTile(
                  activeColor: Colors.green[700],
                  title: Row(children: [
                    Icon(opt['icon'] as IconData, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(opt['label'] as String, style: GoogleFonts.poppins()),
                  ]),
                  value: isSelected,
                  onChanged: (val) => controller.selectedSocials[key] = val ?? false,
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: controller.socialControllers[key],
                      decoration: InputDecoration(
                        hintText: "Link/Nomor ${opt['label']}",
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  )
              ],
            );
          });
        }).toList(),
      ),
    );
  }

  void _showPickerSheet(FormUmkmController controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () { Get.back(); controller.pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () { Get.back(); controller.pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }
}