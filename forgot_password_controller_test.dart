import 'package:aisyiyah_smartlife/modules/forgot_password/controllers/test_forgot_password_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class MockIForgotPasswordRepository extends Mock implements IForgotPasswordRepository {}
class MockIForgotPasswordUIHandler extends Mock implements IForgotPasswordUIHandler {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUserResponse extends Mock implements UserResponse {}
class MockSession extends Mock implements Session {}

void main() {
  late TestForgotPasswordController controller;
  late MockIForgotPasswordRepository mockRepo;
  late MockIForgotPasswordUIHandler mockUI;

  setUpAll(() {
    registerFallbackValue(OtpType.recovery);
  });

  setUp(() {
    Get.testMode = true;
    mockRepo = MockIForgotPasswordRepository();
    mockUI = MockIForgotPasswordUIHandler();

    controller = TestForgotPasswordController(
      repository: mockRepo,
      uiHandler: mockUI,
    );
  });

  group('ForgotPasswordController - sendOtpCode', () {
    test('should show error if email is invalid', () async {
      controller.emailController.text = 'invalid';
      await controller.sendOtpCode();
      verify(() => mockUI.showSnackbar("Error", any(), backgroundColor: any(named: 'backgroundColor'), colorText: any(named: 'colorText'))).called(1);
    });

    test('should call resetPasswordForEmail and navigate to verify otp', () async {
      controller.emailController.text = 'test@example.com';
      when(() => mockRepo.resetPasswordForEmail(any())).thenAnswer((_) async => {});

      await controller.sendOtpCode();

      verify(() => mockRepo.resetPasswordForEmail('test@example.com')).called(1);
      verify(() => mockUI.navigateToVerifyOtp()).called(1);
    });
  });

  group('ForgotPasswordController - verifyOtpCode', () {
    test('should navigate to reset password if OTP is valid', () async {
      controller.emailController.text = 'test@example.com';
      controller.otpController.text = '123456';
      
      final mockAuthResponse = MockAuthResponse();
      final mockSession = MockSession();
      when(() => mockAuthResponse.session).thenReturn(mockSession);
      
      when(() => mockRepo.verifyOTP(
        email: any(named: 'email'),
        token: any(named: 'token'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => mockAuthResponse);

      await controller.verifyOtpCode();

      verify(() => mockUI.navigateToResetPassword()).called(1);
    });
  });

  group('ForgotPasswordController - createNewPassword', () {
    test('should show error if passwords do not match', () async {
      controller.passwordController.text = 'Password123';
      controller.confirmPasswordController.text = 'Different123';
      
      await controller.createNewPassword();

      verify(() => mockUI.showSnackbar('Peringatan', 'Konfirmasi password tidak cocok', backgroundColor: any(named: 'backgroundColor'), colorText: any(named: 'colorText'))).called(1);
    });

    test('should call updateUser and navigate to login on success', () async {
      controller.passwordController.text = 'Password123';
      controller.confirmPasswordController.text = 'Password123';
      
      when(() => mockRepo.updateUser(any())).thenAnswer((_) async => MockUserResponse());

      await controller.createNewPassword();

      verify(() => mockRepo.updateUser('Password123')).called(1);
      verify(() => mockUI.navigateToLogin()).called(1);
    });
  });
}

// Semantic Commit: test(forgot_password): add unit tests for OTP sending, verification, and password reset
