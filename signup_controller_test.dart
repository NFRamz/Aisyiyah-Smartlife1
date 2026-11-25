import 'package:aisyiyah_smartlife/modules/signup/controllers/test_signup_controller.dart';
import 'package:aisyiyah_smartlife/data/services/google_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class MockISignUpRepository extends Mock implements ISignUpRepository {}
class MockISignUpUIHandler extends Mock implements ISignUpUIHandler {}
class MockGoogleAuthService extends Mock implements GoogleAuthService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late TestSignUpController controller;
  late MockISignUpRepository mockRepo;
  late MockISignUpUIHandler mockUI;
  late MockGoogleAuthService mockGoogleAuth;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    
    mockRepo = MockISignUpRepository();
    mockUI = MockISignUpUIHandler();
    mockGoogleAuth = MockGoogleAuthService();
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    when(() => mockRepo.fetchWilayah()).thenAnswer((_) async => []);

    controller = TestSignUpController(
      repository: mockRepo,
      uiHandler: mockUI,
      googleAuthService: mockGoogleAuth,
      supabase: mockSupabase,
    );
  });

  group('SignUpController - Step Navigation', () {
    test('should increment step when member status is set', () {
      controller.currentStep.value = 1;
      controller.setMemberStatus(true);
      expect(controller.isMember.value, true);
      expect(controller.currentStep.value, 2);
    });

    test('should validate email before moving to next step', () async {
      controller.currentStep.value = 2;
      controller.isMember.value = true;
      controller.emailController.text = 'invalid-email';

      controller.nextStep();

      expect(controller.currentStep.value, 2);
      verify(() => mockUI.showSnackbar(any(), 'Masukkan email yang valid', backgroundColor: any(named: 'backgroundColor'), colorText: any(named: 'colorText'))).called(1);
    });

    test('should check email existence and proceed if not exists', () async {
      controller.currentStep.value = 2;
      controller.isMember.value = true;
      controller.emailController.text = 'new@example.com';

      when(() => mockRepo.checkEmailExists('new@example.com')).thenAnswer((_) async => null);

      controller.nextStep();
      
      await Future.delayed(Duration.zero);
      expect(controller.currentStep.value, 3);
    });
  });

  group('SignUpController - handleSignUp', () {
    test('should call signUp and navigate to home on success (Email/Pass)', () async {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'Password123';
      controller.firstNameController.text = 'John';
      controller.lastNameController.text = 'Doe';
      controller.isGoogleAuth.value = false;

      when(() => mockRepo.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => {});

      await controller.handleSignUp();

      verify(() => mockRepo.signUp(
        email: 'test@example.com', 
        password: 'Password123', 
        data: any(named: 'data')
      )).called(1);
      verify(() => mockUI.navigateToHome()).called(1);
    });
  });
}

// Semantic Commit: test(signup): add unit tests for step navigation, email validation, and signup process
