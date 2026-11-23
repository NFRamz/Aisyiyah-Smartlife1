import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:aisyiyah_smartlife/modules/login/controllers/login_controller.dart';
import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks for dependencies
class MockLoginAuthRepository extends Mock implements LoginAuthRepository {}
class MockLoginUiHandler extends Mock implements LoginUiHandler {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockUser extends Mock implements User {}

void main() {
  // Ensures Flutter environment is ready for testing GetX utilities like GetUtils
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoginController controller;
  late MockLoginAuthRepository mockAuthRepository;
  late MockLoginUiHandler mockUiHandler;
  late MockGoogleAuthService mockGoogleAuthService;

  setUp(() {
    mockAuthRepository = MockLoginAuthRepository();
    mockUiHandler = MockLoginUiHandler();
    mockGoogleAuthService = MockGoogleAuthService();

    // Initialize SharedPreferences mock with empty values
    SharedPreferences.setMockInitialValues({});

    controller = LoginController(
      authRepository: mockAuthRepository,
      uiHandler: mockUiHandler,
      googleAuthService: mockGoogleAuthService,
    );
  });

  group('LoginController Unit Tests', () {
    test('handleLogin shows error when email or password is empty', () async {
      controller.emailController.text = '';
      controller.passwordController.text = '';

      await controller.handleLogin();

      verify(() => mockUiHandler.showSnackbar(
            'Error',
            'Email dan password harus diisi',
            Colors.red,
          )).called(1);
    });

    test('handleLogin shows error for invalid email format', () async {
      controller.emailController.text = 'invalidemail';
      controller.passwordController.text = 'password123';

      await controller.handleLogin();

      verify(() => mockUiHandler.showSnackbar(
            'Error',
            'Format email tidak valid',
            Colors.red,
          )).called(1);
    });

    test('handleLogin successful authentication flow', () async {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');

      // Mock successful sign in
      when(() => mockAuthRepository.signInWithPassword(any(), any()))
          .thenAnswer((_) async => mockUser);

      // Mock successful profile retrieval
      when(() => mockAuthRepository.getProfile('user-123'))
          .thenAnswer((_) async => {
                'nama_depan': 'Jane',
                'nama_belakang': 'Doe',
                'email': 'jane.doe@example.com',
                'role_id': 'admin',
                'ranting_id': 'ranting-01',
                'daerah_id': 'daerah-01',
              });

      await controller.handleLogin();

      // Verify navigation to home
      verify(() => mockUiHandler.navigateToHome()).called(1);

      // Verify data is saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      expect(prefs.getString('nama_pengguna'), 'Jane Doe');
      expect(prefs.getString('role'), 'admin');
    });

    test('handleLogin increments failed attempts on AuthException', () async {
      controller.emailController.text = 'wrong@email.com';
      controller.passwordController.text = 'wrongpass';

      when(() => mockAuthRepository.signInWithPassword(any(), any()))
          .thenThrow(const AuthException('Invalid login credentials'));

      await controller.handleLogin();

      expect(controller.failedAttempts.value, 1);
      verify(() => mockUiHandler.showSnackbar(
            'Gagal Login',
            any(),
            Colors.redAccent,
          )).called(1);
    });

    test('togglePasswordVisibility changes the reactive state', () {
      expect(controller.isPasswordVisible.value, false);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, true);
    });
  });
}
