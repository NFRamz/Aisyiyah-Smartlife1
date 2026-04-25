import 'package:aisyiyah_smartlife/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aisyiyah_smartlife/components/button/Button_PrimaryButton.dart';
import 'package:aisyiyah_smartlife/core/values/AppColors.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding : const EdgeInsets.all(24.0),
          child   : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Icon(Icons.spa, size: 80, color: Color(0xFF4A9D9C)),
              const SizedBox(height: 16),
              const Text('Selamat Datang', textAlign: TextAlign.center, style:TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 8),
              const Text('Silakan masuk untuk melanjutkan', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 40),


              TextField(
                controller    : controller.emailController,
                keyboardType  : TextInputType.emailAddress,
                decoration    : const InputDecoration(labelText: 'Alamat Email', prefixIcon: Icon(Icons.email_outlined))
              ),
              const SizedBox(height: 20),

              Obx(() => TextField(
                controller  : controller.passwordController,
                obscureText : !controller.isPasswordVisible.value,
                decoration  : InputDecoration(
                  labelText   : 'Kata Sandi', prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon  : IconButton(icon: Icon(controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility), onPressed: controller.togglePasswordVisibility),
                ),
              )),

              const SizedBox(height: 40),

              Obx(() => PrimaryButton(
                  isLoading : controller.isLoading.value,
                  onTap     : controller.handleLogin,
                  warna     : AppColors.font_green_1,
                  text      : "Masuk",
                  animasi   : Curves.easeInOut
              )),

              const SizedBox(height: 20),


              TextButton(
                onPressed : controller.navigateToSignUp,
                child     : const Text('Belum punya akun? Daftar di sini', style: TextStyle(color: AppColors.font_green_1)),
              ),
              Center(
                child:Row(
                  children: [
                    Expanded(
                        child:Container(
                            margin:const EdgeInsets.only(left: 10,right: 10),
                            child :const Divider())),
                    Text("Atau Coba", style: TextStyle(color: Colors.black54)),
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left:10, right: 10),
                          child : const Divider(),
                        ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed : controller.navigateToMyQuran,
                child     : const Text('Masuk Sebagai Tamu', style: TextStyle(color: AppColors.font_green_1)),
              )
            ],
          ),
        ),
      ),
    );
  }
}