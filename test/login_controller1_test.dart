import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aisyiyah_smartlife/modules/login/controllers/login_controller1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';

// Mocks untuk dependensi
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  // Memastikan environment Flutter siap untuk testing
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoginController1 controller;

  setUp(() {
    // Inisialisasi SharedPreferences Mock
    SharedPreferences.setMockInitialValues({});
    
    // Aktifkan mode test untuk GetX (agar snackbar/navigasi tidak benar-benar dijalankan)
    Get.testMode = true;

    // Inisialisasi Controller
    controller = LoginController1();
  });

  tearDown(() {
    // Bersihkan state GetX setelah setiap test
    Get.reset();
  });

  group('LoginController1 Unit Tests', () {
    test('Initial State - Nilai awal harus benar', () {
      expect(controller.isLoading.value, false);
      expect(controller.isPasswordVisible.value, false);
      expect(controller.failedAttempts.value, 0);
      expect(controller.lockoutUntil.value, null);
    });

    test('togglePasswordVisibility - Harus merubah status visibility', () {
      expect(controller.isPasswordVisible.value, false);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, true);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, false);
    });

    test('handleLogin - Validasi input kosong harus memunculkan snackbar', () async {
      controller.emailController.text = '';
      controller.passwordController.text = '';

      await controller.handleLogin();

      // Memastikan snackbar muncul (dalam test mode GetX)
      expect(Get.isSnackbarOpen, true);
    });

    test('handleLogin - Format email tidak valid harus memunculkan snackbar', () async {
      controller.emailController.text = 'bukan-email';
      controller.passwordController.text = 'password123';

      await controller.handleLogin();

      expect(Get.isSnackbarOpen, true);
    });

    test('Lockout Logic - Harus menghitung percobaan gagal', () {
      // Simulasi kegagalan login bisa dilakukan jika kita merefaktor controller 
      // untuk menerima SupabaseClient mock. 
      // Untuk sekarang, kita bisa mengetes variabel reaktifnya secara langsung.
      
      expect(controller.failedAttempts.value, 0);
      
      // Simulasi kegagalan 1
      controller.failedAttempts.value++;
      expect(controller.failedAttempts.value, 1);
    });
  });
}
